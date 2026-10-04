#!/bin/bash
set -euo pipefail
SOURCE_ISO=${1:?Upstream ISO required}
BUILD_DIR=${2:?Build directory required}
DESTINATION=${3:?Output directory required}
PROJECT=$(cd -- "$(dirname -- "$0")/.." && pwd)
VERSION=$(cat "$PROJECT/VERSION")
OUTPUT="$DESTINATION/lantu-os-$VERSION-amd64.iso"
[[ ! -e "$OUTPUT" ]] || { echo "Refusing to replace existing ISO: $OUTPUT" >&2; exit 1; }
TEMP_ISO="$OUTPUT.building"
[[ ! -e "$TEMP_ISO" ]] || { echo "Unfinished output exists: $TEMP_ISO" >&2; exit 1; }
trap 'rm -f "$TEMP_ISO"' EXIT
(cd "$BUILD_DIR/iso"; find . -type f ! -name md5sum.txt ! -name boot.cat ! -path './isolinux/isolinux.bin' -print0 | LC_ALL=C sort -z | xargs -0 md5sum > md5sum.txt)
args=(-indev "$SOURCE_ISO" -outdev "$TEMP_ISO")
for name in filesystem.squashfs filesystem.packages filesystem.size; do
  args+=(-map "$BUILD_DIR/iso/live/$name" "/live/$name")
done
args+=(-map "$BUILD_DIR/iso/md5sum.txt" /md5sum.txt)
while IFS= read -r -d '' file; do
  args+=(-map "$file" "${file#"$BUILD_DIR/iso"}")
done < <(find "$BUILD_DIR/iso/boot/grub" "$BUILD_DIR/iso/isolinux" -type f \( -name '*.cfg' -o -name '*.conf' \) -print0)
# Keep the original boot image objects. Replacing the whole ISO tree loses the
# association used by xorriso's boot replay for this Debian hybrid image.
xorriso "${args[@]}" -boot_image any replay -volid LANTU_OS_02 -commit
mv "$TEMP_ISO" "$OUTPUT"
trap - EXIT
xorriso -indev "$OUTPUT" -report_el_torito plain -report_system_area plain > "$DESTINATION/boot-layout.txt" 2>&1
(cd "$DESTINATION"; sha256sum "$(basename "$OUTPUT")" > SHA256SUMS)
printf 'Built %s\n' "$OUTPUT"
