#!/bin/bash
set -euo pipefail
PROJECT=$(cd -- "$(dirname -- "$0")/.." && pwd)
cd "$PROJECT/desktop"
npm ci
npm run build
npm run test:sites
mkdir -p "$PROJECT/linux/web"
rsync -a --delete --exclude=.DS_Store dist/client/ "$PROJECT/linux/web/"
printf 'Desktop assets ready: %s\n' "$PROJECT/linux/web"
