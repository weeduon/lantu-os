# 第三方组件与素材

本仓库的 GPL-3.0-or-later 适用于项目自有代码、文档及自有图像。系统镜像是多个组件的组合，各组件继续适用自己的版权与许可证。

| 组件 | 来源及许可说明 |
| --- | --- |
| Debian / Linux / 系统软件包 | Debian 13 KDE Live，保留 `/usr/share/doc/*/copyright`、`/usr/share/common-licenses/` 等上游声明；具体以各包为准 |
| KDE Plasma / Qt | 使用 Debian 提供的软件包，具体 GPL / LGPL 等条款以各包文件为准 |
| PyQt6 / PyQt6-WebEngine | 使用 Debian 提供的 GPL 版本；[Riverbank 许可说明](https://www.riverbankcomputing.com/software/pyqt) |
| Firefox ESR | Mozilla 及其贡献者的软件；保留原名称、版权和包内许可证 |
| React / React DOM / Vite / 插件 | npm 锁文件记录版本；对应包内许可证保留在安装依赖中 |
| Phosphor 图标 | `@phosphor-icons/react`，MIT；构建产物含有图标代码 |
| Noto CJK 字体 / Fcitx5 | Debian 包中保留字体和输入法各自的许可 |
| 固件 | 上游 Live 镜像可能包含 `non-free-firmware`，不可将整个 ISO 宣称为仅含 GPL 软件 |

前端运行时打包组件的原始许可全文保存在 `LICENSES/`，随仓库和镜像内源码副本一起提供。

## 项目图像

- `desktop/public/lantu-os-logo.png`：为本项目通过图像生成工具创作的 A2 澜澜角色，已由项目发起人选定。保持原始图像，不含第三方厂商 Logo。
- `desktop/public/wallpaper.png`：为本项目生成的雪山湖泊壁纸。
- `docs/images/desktop.png`：本项目浏览器界面截图，包含示例内容。

以上自有图像随项目按 GPL-3.0-or-later 提供。在法律认可权利的范围内适用该授权；不提供商标独占性、注册状态或生成图像版权可登记性的保证。修改后发行版本应如实说明来源，不暗示原作者或上游为其背书。

## 对应源码

镜像内的 `/usr/share/doc/lantu-desktop/source/` 包含本项目构建时的源码副本，公开仓库也提供同一项目的源码。

构建同时输出 `packages.tsv` 和 `source-packages.tsv`。Debian 源码通过 `deb-src` 源获取，辅助脚本为 `scripts/fetch-debian-sources.sh`。原始版本若已离开滚动镜像，可从 [Debian snapshot](https://snapshot.debian.org/) 找到。分发者需根据实际分发的二进制版本准备并提供完整对应源码，保留声明；仅列出软件名称、提供本仓库代码或脚本本身，不代表已经提供全部第三方源码。

参考：[Debian 许可证说明](https://www.debian.org/legal/licenses/)。
