#!/bin/bash
set -e

cd kernel_workspace/kernel_platform

echo "=== 克隆 SSG 源码 ==="
git clone --depth 1 --filter=blob:none --sparse \
  https://github.com/ramabondanp/android_kernel_common-5.10.git ../ssg_src
cd ../ssg_src
git sparse-checkout set block

echo "=== 复制到 msm-kernel/block ==="
mkdir -p ../kernel_workspace/kernel_platform/msm-kernel/block
cp block/ssg-iosched.c ../kernel_workspace/kernel_platform/msm-kernel/block/
cp block/ssg-cgroup.c ../kernel_workspace/kernel_platform/msm-kernel/block/ 2>/dev/null || true

echo "=== 复制到 common/block ==="
mkdir -p ../kernel_workspace/kernel_platform/common/block
cp block/ssg-iosched.c ../kernel_workspace/kernel_platform/common/block/
cp block/ssg-cgroup.c ../kernel_workspace/kernel_platform/common/block/ 2>/dev/null || true

echo "=== 修改 msm-kernel/block/Makefile ==="
cd ../kernel_workspace/kernel_platform/msm-kernel/block
if ! grep -q "ssg-" Makefile; then
  cat >> Makefile << 'EOF'

# SSG IO scheduler
ssg-$(CONFIG_MQ_IOSCHED_SSG) := ssg-iosched.o
ssg-$(CONFIG_MQ_IOSCHED_SSG_CGROUP) += ssg-cgroup.o
obj-$(CONFIG_MQ_IOSCHED_SSG) += ssg.o
EOF
fi

echo "=== 修改 msm-kernel/block/Kconfig ==="
if ! grep -q "MQ_IOSCHED_SSG" Kconfig; then
  cat >> Kconfig << 'EOF'

config MQ_IOSCHED_SSG
	tristate "SamSung Generic I/O scheduler"
	default n
	help
	  SamSung Generic IO scheduler.

config MQ_IOSCHED_SSG_CGROUP
	tristate "Control Group for SamSung Generic I/O scheduler"
	default n
	depends on BLK_CGROUP
	depends on MQ_IOSCHED_SSG
	help
	  Control Group for SamSung Generic IO scheduler.
EOF
fi

echo "=== 修改 common/block/Makefile ==="
cd ../kernel_workspace/kernel_platform/common/block
if ! grep -q "ssg-" Makefile; then
  cat >> Makefile << 'EOF'

# SSG IO scheduler
ssg-$(CONFIG_MQ_IOSCHED_SSG) := ssg-iosched.o
ssg-$(CONFIG_MQ_IOSCHED_SSG_CGROUP) += ssg-cgroup.o
obj-$(CONFIG_MQ_IOSCHED_SSG) += ssg.o
EOF
fi

echo "=== 修改 common/block/Kconfig ==="
if ! grep -q "MQ_IOSCHED_SSG" Kconfig; then
  cat >> Kconfig << 'EOF'

config MQ_IOSCHED_SSG
	tristate "SamSung Generic I/O scheduler"
	default n
	help
	  SamSung Generic IO scheduler.

config MQ_IOSCHED_SSG_CGROUP
	tristate "Control Group for SamSung Generic I/O scheduler"
	default n
	depends on BLK_CGROUP
	depends on MQ_IOSCHED_SSG
	help
	  Control Group for SamSung Generic IO scheduler.
EOF
fi

echo "=== 验证 ==="
ls -la ../kernel_workspace/kernel_platform/msm-kernel/block/ssg-* 2>/dev/null || echo "msm-kernel: 未找到 ssg 文件"
ls -la ../kernel_workspace/kernel_platform/common/block/ssg-* 2>/dev/null || echo "common: 未找到 ssg 文件"

echo "=== ✅ SSG 移植完成 ==="
