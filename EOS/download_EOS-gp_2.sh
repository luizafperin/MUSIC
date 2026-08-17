#!/bin/bash

REPO_URL="https://github.com/luizafperin/MUSIC-EOS-data.git"
TEMP_DIR="MUSIC-EOS-data"
TARGET_DIR="EOS-gp"

# Remove old temporary clone if it exists
rm -rf "$TEMP_DIR"

# Clone repository
echo "Cloning MUSIC-EOS-data..."
git clone --depth 1 "$REPO_URL" "$TEMP_DIR"

# Remove existing EOS-gp directory if you want a fresh copy
rm -rf "$TARGET_DIR"

# Copy EOS-gp from the repository
cp -r "$TEMP_DIR/EOS-gp" "$TARGET_DIR"

# Remove temporary repository
rm -rf "$TEMP_DIR"

echo "Done!"
echo "EOS data is now in: $TARGET_DIR"
