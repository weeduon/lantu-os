# 试用和安装

当前为 x86-64 开发预览版。先用虚拟机或备用电脑体验，安装前备份目标磁盘资料。

1. 对下载的完整 ISO 执行 SHA-256 校验。
2. 在虚拟机中把 ISO 作为光驱启动；或使用 Rufus / balenaEtcher 写入 8 GB 以上 U 盘。写入会清除 U 盘数据。
3. 从 U 盘或光驱启动，选择 Lantu OS Live 进入中文 KDE 桌面。
4. 应用菜单中打开“澜图 OS 工作台”；Firefox、Dolphin、系统设置也可单独使用。
5. 确认目标设备的网络、声音、显示和输入正常后，从桌面 / 菜单打开“安装澜图 OS”。仔细检查目标磁盘和分区方案，再开始安装。
6. 安装结束后移除安装介质，再从目标磁盘启动。完整安装及重启验证状态见 [STATUS.md](STATUS.md)。

Live 试用沿用 Debian Live 账户 `user` / 密码 `live`，这不是安装后的账户；安装过程中创建自己的账户。Live 会话通常不保留重启前的数据。

安装澜图请先进入 `Lantu OS Live`，再运行桌面中的 Calamares 安装器。引导菜单保留了上游 Debian 安装入口，它不作为本项目的推荐安装路径。启动背景保留 Debian 上游图案，以注明系统基础。

本次镜像保留上游 BIOS / UEFI 混合启动结构。Secure Boot、双系统、磁盘加密、真实 Wi-Fi、显卡、打印机、休眠和电池续航需要逐机验证。不要据此承诺所有 x86 电脑兼容。

- [Rufus](https://rufus.ie/zh/)
- [balenaEtcher](https://etcher.balena.io/)
- [Debian Live 文档](https://live-team.pages.debian.net/live-manual/html/live-manual/customizing-run-time-behaviours.en.html)
