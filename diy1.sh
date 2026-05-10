#!/bin/bash
set -e

echo "========================================="
echo "ImmortalWrt DIY1"
echo "========================================="

# 删除冲突插件
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/luci/applications/luci-app-poweroff
rm -rf feeds/luci/applications/luci-app-lucky
rm -rf feeds/packages/net/lucky
rm -rf feeds/packages/utils/lucky


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
