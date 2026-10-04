#!/bin/bash
set -euo pipefail
# Run as a regular user with deb-src repositories configured and apt-get update done.
MANIFEST=${1:?Pass source-packages.tsv from the ISO build}
DESTINATION=${2:?Pass a source archive directory}
MANIFEST=$(realpath "$MANIFEST")
mkdir -p "$DESTINATION"
cd "$DESTINATION"
failed=0
while IFS=$'\t' read -r package version; do
  [[ -n "$package" && -n "$version" ]] || continue
  [[ "$package" =~ ^[a-z0-9][a-z0-9+.-]*$ && "$version" != -* ]] || { echo 'Invalid package manifest' >&2; exit 1; }
  if ! apt-get source --download-only "$package=$version"; then
    printf 'Missing exact source: %s %s (check snapshot.debian.org)\n' "$package" "$version" >&2
    failed=1
  fi
done < "$MANIFEST"
exit "$failed"
