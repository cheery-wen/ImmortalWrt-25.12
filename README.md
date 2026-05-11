# ImmortalWrt 25.12 x86_64 固件

基于官方 ImmortalWrt 25.12 源码构建，集成高性能内核与常用网络/存储插件。

## 主要特性

- **平台**：x86_64 (EFI + GRUB, SquashFS, 分区: 32MB + 512MB)
- **包管理**：APK (apk-mbedtls)
- **内核优化**：1000Hz 时钟、BBR 拥塞控制、TCP Fast Open、ZSWAP、Cgroup v2、磁盘队列调度 (mq-deadline/kyber)
- **防火墙**：Firewall4 + nftables (纯 nft 模式，提供 iptables-nft 兼容层)
- **IPv6**：完整支持 (DHCPv6、NAT6、隧道)
- **存储与 USB**：
  - 文件系统：ext4 / exFAT / NTFS3
  - USB 全速 (1.1/2.0/3.0)，UAS 支持
  - 自动挂载、TRIM、S.M.A.R.T.、Samba4 共享
- **网卡驱动**：主流有线网卡 (Intel 1G/10G/2.5G、Realtek、VMware)
- **常用插件**：
  - Argon 主题及配置
  - Passwall (Hysteria, nftables 透明代理)
  - Lucky，DDNS (Cloudflare)，UPnP (nftables)，Zerotier
  - 文件传输，磁盘管理，TTYD，VLMCSD，定时重启
  - CPU 调频，时间控制，nft QoS，Chrony 时间同步
- **网络加速**：Fast Classifier

## 使用方法

1. 下载固件 `*.img.gz` 并解压
2. 写入硬盘/U盘：`dd if=firmware.img of=/dev/sdX bs=4M`
3. 默认 IP：`192.168.5.1`，无密码 (首次需设置)

# 注意事项

- 本固件仅包含有线网络驱动，无 Wi-Fi/声卡支持
- Passwall 使用 nftables 模式，请勿开启 iptables 兼容代理
- 若需 Docker，请手动安装 `dockerd` 及 `luci-app-docker`

## 致谢

- ImmortalWrt
- OpenWrt
- 感谢所有开源贡献者的辛勤付出
