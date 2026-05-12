#!/bin/bash
set -e

echo "🚀 开始注入 ImmortalWrt 25.12 "

# ==================================================
# 1. 版本显示修改 (target.mk 机制)
# ==================================================
# 修改描述信息: OpenWrt (2026.05.11 compiled by cheery) / 25.12 rXXXX
sed -i "s|DISTRIB_DESCRIPTION='%D %V %C'|DISTRIB_DESCRIPTION='OpenWrt ($(date +%Y.%m.%d) compiled by cheery) / %V %C'|g" include/target.mk

# 修改修订号样式: 先重置再追加，防止重复运行脚本导致内容堆叠
sed -i "s|DISTRIB_REVISION:='%R.*'|DISTRIB_REVISION:='%R'|g" include/target.mk
sed -i "s|DISTRIB_REVISION:='%R'|DISTRIB_REVISION:='%R (R$(date +%y.%m.%d))'|g" include/target.mk

# ==================================================
# 2. 彻底删除 feeds 冲突插件 (确保使用 package/ 下手动克隆的版本)
# ==================================================
echo "清理冲突插件..."
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/luci/applications/luci-app-poweroff
rm -rf feeds/luci/applications/luci-app-lucky
rm -rf feeds/packages/net/lucky
rm -rf feeds/packages/utils/lucky
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/packages/net/xray-core
rm -rf feeds/packages/net/sing-box
rm -rf feeds/packages/net/hysteria
rm -rf feeds/packages/net/tuic-client

# ==================================================
# 3. 强制锁定默认主题配置 (files 目录覆盖机制)
# ==================================================
mkdir -p files/etc/config
cat > files/etc/config/luci << "EOF"
config core 'main'
	option lang 'zh_hans'
	option mediaurlbase '/luci-static/argon'
	option resourcebase '/luci-static/resources'

config internal 'themes'
	option Argon '/luci-static/argon'
	option Bootstrap '/luci-static/bootstrap'

config internal 'languages'
	option zh_hans '简体中文 (Chinese Simplified)'

config internal 'main'
	option default_theme 'Argon'
EOF

# ==================================================
# 4. 自适应网口 (路径修改为更通用的 package 覆盖方式)
# ==================================================
BOARD_D_PATH="package/base-files/files/etc/board.d"
mkdir -p "$BOARD_D_PATH"

cat > "$BOARD_D_PATH/02_network" << "EOF"
#!/bin/sh
. /lib/functions.sh
. /lib/functions/uci-defaults.sh

board_config_update

# 获取所有物理网口，按 eth0, eth1 排序
ALL_ETH=$(ls /sys/class/net/ | grep -E '^eth[0-9]+$' | sort -V)
COUNT=$(echo "$ALL_ETH" | wc -l)

if [ "$COUNT" -ge 2 ]; then
    WAN_PORT=$(echo "$ALL_ETH" | head -n1)
    LAN_PORTS=$(echo "$ALL_ETH" | tail -n +2)
    # 将第一个网口设为 WAN，其余全部设为 LAN
    ucidef_set_interfaces_lan_wan "$LAN_PORTS" "$WAN_PORT"
elif [ "$COUNT" -eq 1 ]; then
    ucidef_set_interface_lan "$ALL_ETH"
fi

board_config_flush
exit 0
EOF

chmod +x "$BOARD_D_PATH/02_network"

# board_detect 兜底
mkdir -p package/base-files/files/etc/uci-defaults
cat > package/base-files/files/etc/uci-defaults/99-force-board-detect << "EOF"
#!/bin/sh
/bin/board_detect
exit 0
EOF
chmod +x package/base-files/files/etc/uci-defaults/99-force-board-detect

# ==================================================
# 5. 编译工具链优化 (Golang 26.x )
# ==================================================
echo "更换 Golang 26.x..."
rm -rf dl/go-mod-cache 2>/dev/null || true
rm -rf feeds/packages/lang/golang
git clone --depth 1 -b 26.x https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang
# ==================================================
# 6. 基础系统属性修改
# ==================================================
echo "修改系统默认配置..."
# 修改默认 IP 为 192.168.5.1
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate

# 修改主机名为 OpenWrt
sed -i "s/hostname='ImmortalWrt'/hostname='OpenWrt'/g" package/base-files/files/bin/config_generate

# 移除 root 默认密码
sed -i 's/^root:[^:]*:/root::/' package/base-files/files/etc/shadow

echo "✅ DIY2 最终逻辑修复版注入完成！"
