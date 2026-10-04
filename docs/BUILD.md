# 从源码构建澜图 OS

## 环境

- 独立 Debian 13 amd64 虚拟机；root 权限。脚本会安装构建工具、挂载 chroot，勿在办公电脑主系统直接运行。
- 建议 4 核、8 GB 内存、40 GB 可用空间；联网访问 Debian 软件源和 npm。
- Node.js 22、npm、rsync。前端可在另一台机器构建，随后把项目和 `linux/web/` 一同传入构建机。
- ISO 构建采用官方上游镜像重打包，固定上游哈希，保留其内核和 BIOS / UEFI 引导对象。

## 1. 获取源码与前端资源

```bash
git clone https://github.com/weeduon/lantu-os.git
cd lantu-os
bash scripts/prepare-iso.sh
```

`prepare-iso.sh` 执行 `npm ci`、生产构建、网页服务测试，并将 `desktop/dist/client/` 同步到 `linux/web/`。不要手改生成目录。

## 2. 获取固定上游镜像

```bash
mkdir -p downloads
curl -fL --retry 3 \
  https://cdimage.debian.org/mirror/cdimage/archive/13.6.0-live/amd64/iso-hybrid/debian-live-13.6.0-amd64-kde.iso \
  -o downloads/debian-live-13.6.0-amd64-kde.iso
printf '%s  %s\n' \
  426984f7edf034f4cd49f6218e706a6086588359d34fa0328676451b4a679639 \
  downloads/debian-live-13.6.0-amd64-kde.iso | sha256sum -c -
```

[Debian 原始下载目录](https://cdimage.debian.org/mirror/cdimage/archive/13.6.0-live/amd64/iso-hybrid/) 中提供上游校验和及签名。构建脚本也会强制检查上面的 SHA-256。

## 3. 构建 ISO

在 Debian 构建虚拟机内运行：

```bash
sudo bash linux/build.sh "$PWD/downloads/debian-live-13.6.0-amd64-kde.iso" "$PWD/release"
```

默认缓存目录 `/var/tmp/lantu-desktop-build`。第一次构建会解包根文件系统，安装中文输入、原生工作台及系统控制依赖，复制品牌资源，生成 squashfs，再通过 xorriso 重放原始引导配置。

重用本项目的构建缓存时：

```bash
sudo env LANTU_RESUME=1 LANTU_BUILD_DIR=/var/tmp/lantu-desktop-build \
  bash linux/build.sh "$PWD/downloads/debian-live-13.6.0-amd64-kde.iso" "$PWD/release-new"
```

仅对已确认属于此项目的缓存启用恢复。构建会替换缓存中的自有工作台文件。输出目录不能已有同名 ISO，避免无意覆盖旧版本。

输出包含：

- `lantu-os-0.2.0-preview-amd64.iso`
- `SHA256SUMS`
- `packages.tsv`：实际安装的二进制软件包版本
- `source-packages.tsv`：对应 Debian 源码包名称与版本
- `boot-layout.txt`：BIOS / UEFI 启动布局

```bash
(cd release && sha256sum -c SHA256SUMS)
python3 linux/tests/test_bridge.py
```

原生测试需要 Debian 的 `python3-pyqt6`、`python3-pyqt6.qtwebengine`；可以在已安装依赖的构建 root 中执行。

## 可复现范围

固定了上游 ISO 哈希和 npm 锁文件，但 APT 仓库会更新、文件时间戳也会变化，因此相同配方不保证逐字节相同的 ISO。保留每次发布的源码提交、包版本清单和校验和。需要逐字节重现时，还须固定 Debian snapshot 和构建时间，此版本未实现。

## 发布与源码

ISO 不进 Git 历史。GitHub 单个 Release 资源需小于 2 GiB；如发布镜像，可分卷并附完整镜像和分卷的 SHA-256、合并说明。[GitHub 官方限制](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases)

对外分发镜像前，应按其组件许可证提供相应源码及声明。镜像内包含本项目源码与许可证，路径为 `/usr/share/doc/lantu-desktop/`；第三方源码另见 `source-packages.tsv`、`scripts/fetch-debian-sources.sh` 和 [第三方说明](../THIRD_PARTY_NOTICES.md)。源码下载脚本遇到不可用的准确版本会失败，应从 Debian snapshot 补齐并归档，不能用新版本代替。
