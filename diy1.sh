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

sed -i "s/DISTRIB_DESCRIPTION=.*/DISTRIB_DESCRIPTION='OpenWrt 25.12 ($(TZ=UTC-8 date "+%Y.%m.%d") compiled by cheery)'/g" \
package/base-files/files/etc/openwrt_release

# 删除冲突插件
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config

# Argon
git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone --depth 1 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# Lucky
git clone --depth 1 https://github.com/gdy666/luci-app-lucky.git package/luci-app-lucky

# Passwall
git clone --depth 1 https://github.com/xiaorouji/openwrt-passwall-packages.git package/openwrt-passwall-packages
git clone --depth 1 https://github.com/xiaorouji/openwrt-passwall.git package/luci-app-passwall

# poweroff
git clone --depth 1 https://github.com/esirplayground/luci-app-poweroff.git package/luci-app-poweroff

echo "========================================="
echo "DIY1 完成"
echo "========================================="
