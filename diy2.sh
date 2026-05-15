#!/bin/bash
set -e

echo "🚀 开始注入 ImmortalWrt 25.12 优化补丁"

# ==================================================
# 1. 彻底删除 feeds 冲突插件 (确保使用 package/ 下手动克隆的版本)
# ==================================================
echo "清理冲突插件..."
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/luci/applications/luci-app-lucky
rm -rf feeds/packages/net/lucky
rm -rf feeds/packages/utils/lucky
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/packages/net/xray-core
rm -rf feeds/packages/net/sing-box
rm -rf feeds/packages/net/hysteria
rm -rf feeds/packages/net/tuic-client

# ==================================================
# 2. 自适应网口
# ==================================================
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

# ==================================================
# board_detect 兜底
# ==================================================
mkdir -p package/base-files/files/etc/uci-defaults

cat > package/base-files/files/etc/uci-defaults/99-force-board-detect << "EOF"
#!/bin/sh
/bin/board_detect
exit 0
EOF

chmod +x package/base-files/files/etc/uci-defaults/99-force-board-detect

# ==================================================
# 3. 编译工具链优化 (Golang 26.x )
# ==================================================
echo "更换 Golang 26.x..."
rm -rf dl/go-mod-cache 2>/dev/null || true
rm -rf feeds/packages/lang/golang
git clone --depth 1 -b 26.x https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# ==================================================
# 4. 基础系统属性修改
# ==================================================
echo "修改系统默认配置..."
# 修改默认 IP 为 192.168.5.1
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate

# 修改主机名为 OpenWrt
sed -i "s/hostname='ImmortalWrt'/hostname='OpenWrt'/g" package/base-files/files/bin/config_generate

# 移除 root 默认密码
sed -i 's/^root:[^:]*:/root::/' package/base-files/files/etc/shadow

# ==================================================
# 5. 修改固件版本描述 
# ==================================================
echo "正在注入自定义版本号"

# 提前声明日期变量，确保全局时间戳绝对统一
COMPILE_DATE=$(date +%Y.%m.%d)
CUSTOM_VERSION="OpenWrt (${COMPILE_DATE} compiled by cheery)"
CUSTOM_REVISION="${COMPILE_DATE} compiled by cheery"

# ==========================================
# 顶级版本主控文件补强（全局兜底）
# ==========================================
if [ -f include/version.mk ]; then
    sed -i "s|VERSION_DIST:='.*'|VERSION_DIST:='OpenWrt'|g" include/version.mk
    sed -i "s|VERSION_DIST:=.*|VERSION_DIST:=OpenWrt|g" include/version.mk
    sed -i "s|ImmortalWrt|OpenWrt|g" include/version.mk
fi

# ==========================================
# 25.12 版本定义（Kconfig & 类 image-config 文件）
# ==========================================
find package/base-files/ -type f \( -name "Kconfig" -o -name "image-config.in" -o -name "Config.in" \) -print0 2>/dev/null | xargs -0 -r sed -i "s|default \"ImmortalWrt\"|default \"OpenWrt\"|g"

# 强行重写释放至固件的版本与发布信息（包含 openwrt_version 绝对覆盖）
if [ -d package/base-files/files/etc ]; then
    # 强制重写 openwrt_release
    if [ -f package/base-files/files/etc/openwrt_release ]; then
        sed -i "s|DISTRIB_DESCRIPTION='.*'|DISTRIB_DESCRIPTION='${CUSTOM_VERSION}'|g" package/base-files/files/etc/openwrt_release
        sed -i "s|DISTRIB_ID='.*'|DISTRIB_ID='OpenWrt'|g" package/base-files/files/etc/openwrt_release
        sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='${CUSTOM_REVISION}'|g" package/base-files/files/etc/openwrt_release
    fi
    # 强制重写并固化 openwrt_version 文本内容
    echo "${CUSTOM_REVISION}" > package/base-files/files/etc/openwrt_version
fi

# ==========================================
# 前端与主题无死角清理（含 CSS/Banner/自定义主题 Logo）
# ==========================================
find package/ -type f \( -name "*.htm" -o -name "*.html" -o -name "*.js" -o -name "*.lua" -o -name "*.css" -o -name "*.json" -o -name "*.svg" \) -print0 2>/dev/null | xargs -0 -r sed -i "s|ImmortalWrt|OpenWrt|g"

# 修改 25.12 的 TTY 登录 Banner（SSH 连入时显示的大字）
if [ -f package/base-files/files/etc/banner ]; then
    sed -i "s|ImmortalWrt|OpenWrt|g" package/base-files/files/etc/banner
fi

# ==========================================
#  内核、U-Boot 与内核头文件深度洗网
# ==========================================
find include/ target/ -type f ! -name "diy2.sh" -print0 2>/dev/null | xargs -0 -r sed -i "s|ImmortalWrt|OpenWrt|g"
find target/ -type f -name "*Makefile*" -print0 2>/dev/null | xargs -0 -r sed -i "s|ImmortalWrt|OpenWrt|g"

# ==========================================
#  安全的缓存清理（保护编译环境与配置状态）
# ==========================================
rm -rf build_dir/target-*/base-files*
rm -rf build_dir/target-*/luci-theme-*
rm -rf build_dir/target-*/luci-base*
rm -rf build_dir/target-*/luci-mod-*
rm -rf staging_dir/target-*/root-*
rm -rf staging_dir/target-*/pkginfo/base-files.version

# 仅精准删除 tmp/ 目录下的配置扫描快照，绝不破坏核心状态锁
if [ -d tmp ]; then
    find tmp/ -type f -name "*.mk" -o -name "*.info" -o -name "*info*" 2>/dev/null | xargs rm -f 2>/dev/null || true
fi

# ==================================================
# 6. 修改默认主题
# ==================================================
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile || true

echo "✅ DIY2 ImmortalWrt 25.12 优化补丁注入完成！"
