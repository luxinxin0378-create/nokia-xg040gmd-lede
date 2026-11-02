# Nokia XG-040G-MD (AN7581 UBI) LEDE 自动编译

目标：`airoha/an7581`，设备配置：`nokia_xg-040g-md-ubi`。源码来自 `coolsnowwolf/lede`。

## 启动编译
1. 打开仓库的 **Actions** 页面。
2. 选择 **Nokia XG-040G-MD Custom Firmware**。
3. 点击 **Run workflow**，默认设备配置保持不变，建议并行任务选 2。
4. 编译成功后打开运行记录底部 **Artifacts**，下载 `nokia-xg040gmd-ubi-firmware`。

上传工作流文件到默认分支后，首次也会因 push 事件自动启动一次编译。

## 已配置的功能候选
- USB 5G：QMI、MBIM、NCM、ECM/RNDIS、USB 串口和 modeswitch 工具
- 5G 模块目标：RM500Q-GL、RM520N-GL、FM650（最终取决于 USB composition、VID:PID 和协议）
- USB Wi-Fi 候选：MTK、Qualcomm/Atheros、Realtek；具体 AP 热点能力必须按网卡 USB ID 和驱动验证
- LuCI 插件候选：OpenClash、PassWall 2、流量统计、系统监控、ttyd、文件管理、WOL、DDNS、QModem

并非每个可选包都保证存在于当前 feeds。编译产物会包含 `package-availability.txt`，明确列出实际启用情况。不要同时运行多个透明代理栈，避免 DNS/防火墙规则冲突。

## NAND 与刷机安全
SkyHigh S35ML02G300 与 Fudan FM25G02B 不能仅凭型号名称认定可共用启动链。此工作流只构建系统固件，不构建、不刷写 preloader、BL31/U-Boot，也不会自动刷机。Fudan NAND 必须先确认设备现有启动链支持该芯片及 UBI 布局。

刷机前必须对本机全闪存备份并校验，尤其保留 `bosa`、`ri` 等设备身份/校准数据；严禁使用其他设备的分区备份。不要把 recovery、bootloader 文件当作普通 sysupgrade 镜像。

QModem 仓库许可证可能限制商业用途；集成和再发布前请自行核对完整许可证。QModem 不能替代内核驱动。


## Build trigger

提交此文件会触发 GitHub Actions 自动编译。
