#!/bin/bash
set -e

echo "========================================="
echo "ImmortalWrt DIY1"
echo "========================================="

# 修改默认IP
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate

# 修改主机名
sed -i "s/hostname='ImmortalWrt'/hostname='OpenWrt'/g" package/base-files/files/bin/config_generate

# 清除默认密码
sed -i 's/root::0:0:99999:7:::/root::::::::/g' package/base-files/files/etc/shadow 2>/dev/null || true

# 获取 Git 的修订版本号 (如 R26.02.20)
GET_REVISION="R$(date +%y.%m.%d)"

# 构造完全符合截图样式的描述信息
cat > package/base-files/files/etc/openwrt_release <<EOF
DISTRIB_ID='ImmortalWrt'
DISTRIB_RELEASE='25.12'
DISTRIB_REVISION='$GET_REVISION'
DISTRIB_TARGET='x86/64'
DISTRIB_ARCH='x86_64'
DISTRIB_DESCRIPTION='OpenWrt ($(date +%Y.%m.%d)) compiled by cheery)$GET_REVISION / LuCI openwrt-25.12 branch'
DISTRIB_TAINTS='no-all busybox'
EOF

# 删除冲突插件
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config

# Argon
git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone --depth 1 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# Lucky
git clone --depth 1 https://github.com/gdy666/luci-app-lucky.git package/luci-app-lucky

# PassWall
git clone --depth 1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git package/openwrt-passwall-packages
git clone --depth 1 https://github.com/Openwrt-Passwall/openwrt-passwall.git package/luci-app-passwall
echo "✅ PassWall 已添加"

# poweroff
git clone --depth 1 https://github.com/esirplayground/luci-app-poweroff.git package/luci-app-poweroff

echo "========================================="
echo "DIY1 完成"
echo "========================================="
