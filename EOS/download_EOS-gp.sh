#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/luizafperin/MUSIC-EOS-data.git"
TEMP_DIR="MUSIC-EOS-data"
TARGET_DIR="EOS-gp"

rm -rf "$TEMP_DIR" "$TARGET_DIR"

echo "Downloading EOS data..."

git -c http.version=HTTP/1.1 clone \
    --depth 1 \
    --single-branch \
    --filter=blob:none \
    --sparse \
    "$REPO_URL" "$TEMP_DIR"

cd "$TEMP_DIR"

git sparse-checkout set EOS-gp

cd ..

mv "$TEMP_DIR/EOS-gp" "$TARGET_DIR"

rm -rf "$TEMP_DIR"

echo "EOS data is now in: $TARGET_DIR"
