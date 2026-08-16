#!/bin/bash
set -e

echo "=== [SSG] 开始 ==="

# 进入 kernel_platform
cd kernel_workspace/kernel_platform

# 克隆 SSG 源码
echo "=== [SSG] 克隆仓库 ==="
git clone --depth 1 --filter=blob:none --sparse \
  https://github.com/ramabondanp/android_kernel_common-5.10.git ../ssg_src || exit 1
cd ../ssg_src
git sparse-checkout set block

# 复制到 msm-kernel/block
echo "=== [SSG] 复制到 msm-kernel/block ==="
mkdir -p ../kernel_workspace/kernel_platform/msm-kernel/block
cp block/ssg-iosched.c ../kernel_workspace/kernel_platform/msm-kernel/block/
cp block/ssg-cgroup.c ../kernel_workspace/kernel_platform/msm-kernel/block/ 2>/dev/null || true

# 复制到 common/block
echo "=== [SSG] 复制到 common/block ==="
mkdir -p ../kernel_workspace/kernel_platform/common/block
cp block/ssg-iosched.c ../kernel_workspace/kernel_platform/common/block/
cp block/ssg-cgroup.c ../kernel_workspace/kernel_platform/common/block/ 2>/dev/null || true

# 修改 msm-kernel/block/Makefile
echo "=== [SSG] 修改 msm-kernel/block/Makefile ==="
cd ../kernel_workspace/kernel_platform/msm-kernel/block
if grep -q "ssg-" Makefile; then
  echo "Makefile 已包含 SSG，跳过修改"
else
  cat >> Makefile << 'EOF'

# SSG IO scheduler
ssg-$(CONFIG_MQ_IOSCHED_SSG) := ssg-iosched.o
ssg-$(CONFIG_MQ_IOSCHED_SSG_CGROUP) += ssg-cgroup.o
obj-$(CONFIG_MQ_IOSCHED_SSG) += ssg.o
EOF
fi

# 修改 msm-kernel/block/Kconfig
echo "=== [SSG] 修改 msm-kernel/block/Kconfig ==="
if grep -q "MQ_IOSCHED_SSG" Kconfig; then
  echo "Kconfig 已包含 SSG，跳过修改"
else
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

# 修改 common/block/Makefile
echo "=== [SSG] 修改 common/block/Makefile ==="
cd ../kernel_workspace/kernel_platform/common/block
if grep -q "ssg-" Makefile; then
  echo "Makefile 已包含 SSG，跳过修改"
else
  cat >> Makefile << 'EOF'

# SSG IO scheduler
ssg-$(CONFIG_MQ_IOSCHED_SSG) := ssg-iosched.o
ssg-$(CONFIG_MQ_IOSCHED_SSG_CGROUP) += ssg-cgroup.o
obj-$(CONFIG_MQ_IOSCHED_SSG) += ssg.o
EOF
fi

# 修改 common/block/Kconfig
echo "=== [SSG] 修改 common/block/Kconfig ==="
if grep -q "MQ_IOSCHED_SSG" Kconfig; then
  echo "Kconfig 已包含 SSG，跳过修改"
else
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

# 验证
echo "=== [SSG] 验证 ==="
ls -la ../kernel_workspace/kernel_platform/msm-kernel/block/ssg-* 2>/dev/null || echo "msm-kernel: ssg 文件不存在"
ls -la ../kernel_workspace/kernel_platform/common/block/ssg-* 2>/dev/null || echo "common: ssg 文件不存在"

echo "=== ✅ SSG 步骤全部完成 ==="
echo "SSG_OK=true" >> $GITHUB_ENV
