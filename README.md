# ImmortalWrt 25.12 x86_64 固件

基于官方 ImmortalWrt 25.12 源码深度定制，集成高性能网络驱动与常用插件。

## 固件特性

- **目标平台**：x86_64 (EFI + GRUB，SquashFS)
- **分区大小**：内核 32MB + 根文件系统 512MB（满足全驱动及 APK 空间需求）
- **包管理器**：APK (apk-mbedtls)
- **防火墙**：Firewall4 + nftables（完整支持 tproxy/redir/offload 等模块，无 iptables 遗留，兼容层 iptables-nft）
- **IPv6**：完整支持（DHCPv6、NAT6、隧道、odhcp6c + odhcpd-ipv6only）
- **内核优化**：
  - 时钟频率 1000Hz
  - BBR 拥塞控制（默认开启）
  - TCP FastOpen、ECN 支持
  - Cgroup 内存/进程隔离
  - ZRAM 与 ZSWAP 内存压缩
  - 磁盘调度 mq-deadline / kyber
  - SMT / MC 调度优化
- **存储与 SSD 支持**：
  - USB 全速驱动（OHCI/UHCI/EHCI/xHCI）
  - 文件系统：ext4 / exFAT / NTFS3
  - 自动挂载、fstrim、S.M.A.R.T. 监控
  - Samba4 网络共享
- **虚拟化与容器**：KVM（Intel/AMD）、Docker 兼容（veth、br-netfilter）
- **有线网卡驱动**：
  - Intel：e1000/e1000e/igb/igc/ixgbe/i40e
  - Realtek：r8125 / r8168
  - VMware VMXNET3
  - USB 网卡：ASIX AX88179、Realtek RTL8152
- **预装插件**：
  - Argon 主题及配置
  - Passwall（Hysteria，nftables 透明代理）
  - Lucky（全能工具）
  - Diskman 磁盘管理（含 btrfs/lsblk/mdadm）
  - UPnP（nftables 后端）
  - Zerotier、VLMCSD、CPUFreq 调节、定时重启、Nft-QoS、文件传输、TTYD 终端
  - DDNS（含 Cloudflare 脚本）
  - 时间同步（chrony）、HD idle 休眠、Samba4
- **构建格式**：GZIP 压缩的 EFI 镜像

## 默认配置

- **管理地址**：`192.168.5.1`
- **主机名**：`OpenWrt`
- **登录密码**：无（首次登录请立即设置密码）
- **WAN/LAN 自适应**：系统自动识别网口，若存在 `eth0, eth1...` 则 `eth0` 为 WAN，其余为 LAN；仅单网口时全为 LAN

## 使用方法

1. 下载固件 `*.img.gz` 并解压：
   ```bash
   gunzip firmware.img.gz

## 注意事项

- 本固件不包含无线网卡驱动及声卡驱动，仅支持有线网络。
- Passwall 已强制使用 nftables 模式，请勿开启 iptables 兼容代理。
- 如需使用 Docker，请手动安装 dockerd 及 luci-app-docker（固件已集成所需内核模块）。
- 固件已默认开启 BBR + Fast Classifier 加速，无需额外配置。

## 致谢

- ImmortalWrt 
- OpenWrt 
- 感谢所有开源贡献者的辛勤付出
