#!/bin/bash
set -euo pipefail
# Run inside a disposable Debian 13 amd64 builder as root.
SOURCE_ISO=${1:?Pass the Debian 13.6 KDE amd64 ISO}
DESTINATION=${2:?Pass an output directory}
SOURCE_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
PROJECT=$(dirname "$SOURCE_DIR")
VERSION=$(cat "$PROJECT/VERSION")
BUILD_DIR=${LANTU_BUILD_DIR:-/var/tmp/lantu-desktop-build}
EXPECTED=426984f7edf034f4cd49f6218e706a6086588359d34fa0328676451b4a679639
[[ $(id -u) == 0 ]] || { echo 'Run as root inside the build VM.' >&2; exit 1; }
[[ $(uname -m) == x86_64 ]] || { echo 'amd64 builder required.' >&2; exit 1; }
[[ -f "$SOURCE_DIR/web/index.html" && -f "$SOURCE_DIR/web/lantu-os-logo.png" ]] || { echo 'Run scripts/prepare-iso.sh first.' >&2; exit 1; }
printf '%s  %s\n' "$EXPECTED" "$SOURCE_ISO" | sha256sum -c -
[[ ! -e "$BUILD_DIR" || "${LANTU_RESUME:-0}" == 1 ]] || { echo "Build directory already exists: $BUILD_DIR (set LANTU_RESUME=1 to resume this build)" >&2; exit 1; }
mkdir -p "$BUILD_DIR" "$DESTINATION"
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends xorriso squashfs-tools rsync ca-certificates
if [[ ! -d "$BUILD_DIR/root" ]]; then
  xorriso -osirrox on -indev "$SOURCE_ISO" -extract / "$BUILD_DIR/iso"
  chmod -R u+w "$BUILD_DIR/iso"
  unsquashfs -processors 4 -d "$BUILD_DIR/root" "$BUILD_DIR/iso/live/filesystem.squashfs"
fi
[[ -x "$BUILD_DIR/root/usr/bin/dpkg" ]] || { echo "Incomplete root filesystem" >&2; exit 1; }
ROOT="$BUILD_DIR/root"
cleanup() {
  for target in run/live/medium dev/pts dev proc sys; do umount "$ROOT/$target" 2>/dev/null || true; done
}
trap cleanup EXIT
mkdir -p "$ROOT/run/live/medium"
mount --bind "$BUILD_DIR/iso" "$ROOT/run/live/medium"
mount --bind /dev "$ROOT/dev"
mount --bind /dev/pts "$ROOT/dev/pts"
mount -t proc proc "$ROOT/proc"
mount -t sysfs sysfs "$ROOT/sys"
rm -f "$ROOT/etc/resolv.conf"
cp -L /etc/resolv.conf "$ROOT/etc/resolv.conf"
printf '#!/bin/sh\nexit 101\n' > "$ROOT/usr/sbin/policy-rc.d"
chmod 755 "$ROOT/usr/sbin/policy-rc.d"
cat > "$ROOT/etc/apt/sources.list" <<'APT'
deb https://deb.debian.org/debian trixie main non-free-firmware
deb-src https://deb.debian.org/debian trixie main non-free-firmware
deb https://deb.debian.org/debian trixie-updates main non-free-firmware
deb-src https://deb.debian.org/debian trixie-updates main non-free-firmware
deb https://security.debian.org/debian-security trixie-security main non-free-firmware
deb-src https://security.debian.org/debian-security trixie-security main non-free-firmware
APT
chroot "$ROOT" apt-get update
chroot "$ROOT" apt-get install -y --no-install-recommends python3-pyqt6 python3-pyqt6.qtwebengine qdbus-qt6 firefox-esr-l10n-zh-cn fonts-noto-cjk fcitx5 fcitx5-chinese-addons fcitx5-frontend-qt6 plasma-nm plasma-pa powerdevil wireplumber
# Remove the old preview launchers when explicitly resuming its build cache.
rm -f "$ROOT/usr/bin/han-desktop" "$ROOT/usr/bin/han-first-login" "$ROOT/usr/share/applications/han-desktop.desktop" "$ROOT/etc/xdg/autostart/han-first-login.desktop" "$ROOT/etc/han-desktop-release"
rm -rf "$ROOT/usr/share/han-desktop" "$ROOT/usr/share/wallpapers/HanDesktop" "$ROOT/usr/share/doc/han-desktop"
rsync -a --exclude=.DS_Store "$SOURCE_DIR/overlay/" "$ROOT/"
install -m 755 "$SOURCE_DIR/native/lantu-desktop.py" "$ROOT/usr/bin/lantu-desktop"
mkdir -p "$ROOT/usr/share/lantu-desktop/web" "$ROOT/usr/share/wallpapers/LantuOS"
rsync -a --delete --exclude=.DS_Store "$SOURCE_DIR/web/" "$ROOT/usr/share/lantu-desktop/web/"
install -m 644 "$PROJECT/desktop/public/wallpaper.png" "$ROOT/usr/share/wallpapers/LantuOS/wallpaper.png"
install -Dm644 "$PROJECT/desktop/public/lantu-os-logo.png" "$ROOT/usr/share/pixmaps/lantu-os.png"
install -m644 "$PROJECT/desktop/public/lantu-os-logo.png" "$ROOT/etc/calamares/branding/lantu/lantu-os-logo.png"
sed -i 's/^branding: .*/branding: lantu/' "$ROOT/etc/calamares/settings.conf"
sed -i -e 's/^Name=.*/Name=Install Lantu OS/' -e 's/^Icon=.*/Icon=lantu-os/' -e '/^Name\[zh_CN\]=/d' "$ROOT/usr/share/applications/calamares-install-debian.desktop"
printf '\nName[zh_CN]=安装澜图 OS\n' >> "$ROOT/usr/share/applications/calamares-install-debian.desktop"
# Override display metadata; retain Debian identifiers for package compatibility.
cp -L "$ROOT/etc/os-release" "$ROOT/etc/os-release.lantu-tmp"
rm "$ROOT/etc/os-release"
mv "$ROOT/etc/os-release.lantu-tmp" "$ROOT/etc/os-release"
sed -i -e "s/^PRETTY_NAME=.*/PRETTY_NAME=\"澜图 OS $VERSION (Debian 13)\"/" -e 's/^NAME=.*/NAME="澜图 OS"/' "$ROOT/etc/os-release"
mkdir -p "$ROOT/usr/share/doc/lantu-desktop/source"
rsync -a --exclude=.git --exclude=node_modules --exclude=dist --exclude=web --exclude=release --exclude=.DS_Store "$PROJECT/" "$ROOT/usr/share/doc/lantu-desktop/source/"
install -m644 "$PROJECT/LICENSE" "$ROOT/usr/share/doc/lantu-desktop/COPYING"
chmod 755 "$ROOT/usr/bin/lantu-first-login"
sed -i 's/^# *zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' "$ROOT/etc/locale.gen"
chroot "$ROOT" locale-gen
printf 'LANG=zh_CN.UTF-8\n' > "$ROOT/etc/default/locale"
chroot "$ROOT" python3 -c 'from PyQt6.QtWebEngineWidgets import QWebEngineView; from PyQt6.QtWebChannel import QWebChannel; print("Native bridge dependencies OK")'
chroot "$ROOT" python3 -m py_compile /usr/bin/lantu-desktop
chroot "$ROOT" dpkg-query -W -f='${Package}\t${Version}\n' > "$DESTINATION/packages.tsv"
chroot "$ROOT" dpkg-query -W -f='${source:Package}\t${source:Version}\n' | LC_ALL=C sort -u > "$DESTINATION/source-packages.tsv"
cp "$DESTINATION/source-packages.tsv" "$ROOT/usr/share/doc/lantu-desktop/source-packages.tsv"
rm -f "$ROOT/usr/sbin/policy-rc.d"
chroot "$ROOT" apt-get clean
rm -f "$ROOT/etc/resolv.conf"
ln -s /run/NetworkManager/resolv.conf "$ROOT/etc/resolv.conf"
rm -f "$ROOT/etc/machine-id"
touch "$ROOT/etc/machine-id"
rm -f "$ROOT/var/lib/dbus/machine-id"
ln -s /etc/machine-id "$ROOT/var/lib/dbus/machine-id"
cleanup
trap - EXIT
find "$BUILD_DIR/iso/boot/grub" "$BUILD_DIR/iso/isolinux" -type f \( -name '*.cfg' -o -name '*.conf' \) -print0 | xargs -0 -r sed -i -e 's/ locales=zh_CN.UTF-8 keyboard-layouts=us timezone=Asia\/Shanghai//g' -e 's/boot=live/boot=live locales=zh_CN.UTF-8 keyboard-layouts=us timezone=Asia\/Shanghai/g' -e 's/Debian GNU\/Linux Live/Lantu OS 0.2 (Debian 13)/g' -e 's/Han Desktop (Debian 13)/Lantu OS 0.2 (Debian 13)/g'
rm -f "$BUILD_DIR/iso/live/filesystem.squashfs"
mksquashfs "$ROOT" "$BUILD_DIR/iso/live/filesystem.squashfs" -comp zstd -Xcompression-level 6 -b 1M -processors 4 -noappend
cp "$DESTINATION/packages.tsv" "$BUILD_DIR/iso/live/filesystem.packages"
du -sx --block-size=1 "$ROOT" | cut -f1 > "$BUILD_DIR/iso/live/filesystem.size"
bash "$SOURCE_DIR/pack-iso.sh" "$SOURCE_ISO" "$BUILD_DIR" "$DESTINATION"
