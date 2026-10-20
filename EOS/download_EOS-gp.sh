#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/luizafperin/MUSIC-EOS-data.git"
TEMP_DIR="MUSIC-EOS-data"
TARGET_DIR="EOS-gp"

rm -rf "$TEMP_DIR" "$TARGET_DIR"

echo "Downloading EOS data..."

git clone \
    --depth 1 \
    --single-branch \
    --sparse \
    "$REPO_URL" "$TEMP_DIR"

cd "$TEMP_DIR"
git sparse-checkout set EOS-gp
cd ..

cp -r "$TEMP_DIR/EOS-gp" "$TARGET_DIR"
rm -rf "$TEMP_DIR"

echo "EOS data is now in: $TARGET_DIR"

