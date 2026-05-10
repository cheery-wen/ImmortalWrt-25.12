# ImmortalWrt 25.12 x86_64 固件

基于官方 ImmortalWrt 25.12 源码构建，集成常用网络工具与硬件驱动。

## 主要特性

- **平台**：x86_64 (EFI + GRUB, SquashFS, 分区: 32MB+320MB)
- **包管理**：APK (apk-mbedtls)
- **防火墙**：Firewall4 + nftables (无 iptables 遗留，兼容层 iptables-nft)
- **IPv6**：完整支持 (DHCPv6, odhcp6c, odhcpd-ipv6only)
- **网络优化**：BBR 拥塞控制，TUN，Fast Classifier 加速
- **存储支持**：USB 3.0/2.0，文件系统 ext4/exFAT/f2fs/ntfs3/vfat
- **虚拟化**：KVM (Intel/AMD)，Docker 兼容 (veth, br-netfilter)
- **网卡驱动**：主流有线网卡 (Intel 1G/10G/2.5G, Realtek, Broadcom, Mellanox, VMware)
- **常用插件**：
  - Argon 主题及配置
  - Passwall (Hysteria, nftables 透明代理)
  - Lucky，DDNS (Cloudflare)，UPnP (nftables)，Zerotier
  - 文件传输，磁盘管理，Samba4，TTYD，VLMCSD，定时重启，URL 过滤
- **构建格式**：GZIP 压缩的 EFI 镜像

## 使用方法

1. 下载固件 `*.img.gz` 并解压
2. 写入硬盘/U盘：`dd if=firmware.img of=/dev/sdX bs=4M`
3. 默认 IP：`192.168.5.1`，无密码 (首次需设置)


注意事项

· 本固件仅包含有线网络驱动，无 Wi-Fi/声卡支持
· Passwall 使用 nftables 模式，请勿开启 iptables 兼容代理
· 若需 Docker，请手动安装 dockerd 及 luci-app-docker

致谢

· 感谢 ImmortalWrt 项目提供源码
· 感谢 OpenWrt 社区
· 感谢所有开源贡献者的辛勤付出
