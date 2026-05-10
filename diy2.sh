#!/bin/bash

echo "正在注入 ImmortalWrt 25.12 配置..."

# 自适应网口
BOARD_D_PATH="target/linux/x86/base-files/etc/board.d"
mkdir -p "$BOARD_D_PATH"

cat > "$BOARD_D_PATH/02_network" << "EOF"
#!/bin/sh
. /lib/functions.sh
. /lib/functions/uci-defaults.sh

board_config_update

ALL_ETH=$(ls /sys/class/net/ | grep -E '^eth[0-9]+$' | grep -v '@' | sort -V)
COUNT=$(echo "$ALL_ETH" | wc -l)

if [ "$COUNT" -ge 2 ]; then
    WAN_PORT=$(echo "$ALL_ETH" | head -n1)
    LAN_PORTS=$(echo "$ALL_ETH" | tail -n +2 | tr '\n' ' ' | sed 's/ $//')
    ucidef_set_interfaces_lan_wan "$LAN_PORTS" "$WAN_PORT"
elif [ "$COUNT" -eq 1 ]; then
    ucidef_set_interface_lan "$ALL_ETH"
fi

board_config_flush
exit 0
EOF

chmod +x "$BOARD_D_PATH/02_network"

# board_detect兜底
mkdir -p package/base-files/files/etc/uci-defaults

cat > package/base-files/files/etc/uci-defaults/99-force-board-detect << "EOF"
#!/bin/sh
/bin/board_detect
exit 0
EOF

chmod +x package/base-files/files/etc/uci-defaults/99-force-board-detect

# 清理go缓存
rm -rf dl/go-mod-cache 2>/dev/null || true

# Golang 1.26
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 26.x feeds/packages/lang/golang

# 修改默认IP
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate

# 修改主机名
sed -i "s/hostname='ImmortalWrt'/hostname='OpenWrt'/g" package/base-files/files/bin/config_generate

# 清除默认密码
sed -i 's/root::0:0:99999:7:::/root::::::::/g' package/base-files/files/etc/shadow 2>/dev/null || true

# 获取 Git 的修订版本号 (如 R26.02.20)
GET_REVISION="R$(date +%y.%m.%d)"

# 修改固件版本
cat > package/base-files/files/etc/openwrt_release <<EOF
DISTRIB_ID='ImmortalWrt'
DISTRIB_RELEASE='25.12'
DISTRIB_REVISION='$GET_REVISION'
DISTRIB_TARGET='x86/64'
DISTRIB_ARCH='x86_64'
DISTRIB_DESCRIPTION='OpenWrt ($(date +%Y.%m.%d)) compiled by cheery)$GET_REVISION / LuCI openwrt-25.12 branch'
DISTRIB_TAINTS='no-all busybox'
EOF

# 默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile || true

echo "DIY2 执行完成"
