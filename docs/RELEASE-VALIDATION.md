# 0.2.0-preview 构建与验证记录

验证日期：2026-10-05。目标架构：Intel / AMD x86-64。

## 交付文件

- 镜像：`lantu-os-0.2.0-preview-amd64.iso`
- 大小：4,395,958,272 字节（约 4.09 GiB）
- SHA-256：`d5f0f3e986bcd6523d7b5cded76e548a247ae74299419e26644aff18ae82d34e`
- 构建源码：[2a3f8ac](https://github.com/weeduon/lantu-os/commit/2a3f8ac8f83bb5ab913582067cf1ea04604f2e11)
- 源码归档：`lantu-os-0.2.0-preview-source.tar.gz`，SHA-256：`1a67db662a7c863cf27723bc95ccb6775193327957767cef155c4d8c896496af`

源码已公开。ISO 本次以本地文件交付，尚未作为 GitHub Release 资源上传。仓库中的 [版本清单](releases/0.2.0-preview/manifest.json)、[软件包清单](releases/0.2.0-preview/packages.tsv) 和 [源码包清单](releases/0.2.0-preview/source-packages.tsv) 对应此镜像。源码归档固定为上面的构建提交，不包含随后添加的本验证记录。

## 已通过

| 检查 | 结果 |
| --- | --- |
| 固定上游 Debian ISO SHA-256 | 与构建脚本规定值一致 |
| 前端生产构建 | 通过 |
| 网页服务测试 | 4 / 4 通过 |
| 原生桥接测试 | 4 / 4 通过：音量边界、缺失设备、设置白名单、浏览器协议限制 |
| GitHub CI | [构建提交的检查通过](https://github.com/weeduon/lantu-os/actions/runs/37237535569) |
| 原生界面启动 | Qt WebEngine 成功加载本地 HTML、JS、CSS、A2 Logo 和壁纸；未发现 JavaScript 控制台错误 |
| ISO 引导结构 | 保留 BIOS + UEFI El Torito 及混合 MBR / GPT 结构 |
| UEFI 实际启动 | QEMU / OVMF 到达最终镜像的 Lantu OS Live 引导菜单 |
| 镜像内容 | 从最终 ISO 提取 squashfs，核对原生程序、构建脚本、系统名称、安装器品牌、Logo 和 React MIT 许可证 |
| 完整 ISO 校验 | Debian 构建机与 macOS 主机 SHA-256 一致 |

A2 Logo SHA-256：`e04e67d61e442a5312b80f2dac21c4f70b2775967652e357f745b8ef5de039de`，与选定原图一致。

原生启动检查使用 offscreen 软件渲染；Vulkan / GPU 不可用提示属于该测试环境，不能视为真实显卡兼容性测试。UEFI 菜单验证也不能替代完整 Live 桌面及安装测试。

## 尚未完成

- 本轮最终 ISO 的完整 Live 桌面交互验收。
- 安装到空磁盘、创建账户并从硬盘重启的全过程。
- 真机 BIOS、Secure Boot、双系统、Wi-Fi、显卡、声音输出、打印、休眠和真实电池测试。
- 真实 AI 模型、文档索引和组织身份 / 策略管理。

此前 0.1 镜像的 Live 桌面和音量验证记录见 [STATUS.md](STATUS.md)，不能替代本版本的完整验收。本版本应作为开发预览镜像使用。
