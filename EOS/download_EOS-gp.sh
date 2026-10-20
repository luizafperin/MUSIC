

#!/usr/bin/env bash
set -euo pipefail

RECORD_ID="23511754"
FILENAME="EOS-gp.tar.gz"

URL="https://zenodo.org/records/${RECORD_ID}/files/${FILENAME}?download=1"

TARGET_DIR="EOS-gp"
EOS_PATH="EOS-gp/Tsw_136/training"

EXPECTED_MD5="3bdd007eda07c270c66b759a6066f307"

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "Downloading EOS training data from Zenodo..."

# Download archive, retrying interrupted transfers
curl -fL \
    --retry 10 \
    --retry-delay 5 \
    --connect-timeout 30 \
    --continue-at - \
    "$URL" \
    -o "$TEMP_DIR/$FILENAME"

echo "Verifying checksum..."

echo "$EXPECTED_MD5  $TEMP_DIR/$FILENAME" | md5sum -c -

echo "Extracting EOS training data..."

mkdir -p "$TEMP_DIR/extracted"

tar -xzf "$TEMP_DIR/$FILENAME" \
    -C "$TEMP_DIR/extracted"

# Verify expected directory exists
if [[ ! -d "$TEMP_DIR/extracted/$EOS_PATH" ]]; then
    echo "ERROR: Expected directory not found in archive:"
    echo "$EOS_PATH"
    echo "Check the archive structure with:"
    echo "tar -tzf $FILENAME | head"
    exit 1
fi

# Preserve MUSIC directory structure
mkdir -p "$TARGET_DIR/Tsw_136"

# Replace old training directory only after extraction succeeds
rm -rf "$TARGET_DIR/Tsw_136/training"

mv "$TEMP_DIR/extracted/$EOS_PATH" \
   "$TARGET_DIR/Tsw_136/training"

echo "EOS training data downloaded successfully!"
echo "Location: $TARGET_DIR/Tsw_136/training"


