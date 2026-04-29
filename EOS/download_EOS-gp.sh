#!/usr/bin/env bash
set -euo pipefail

L=400
S=15

EOS_TYPES=("hrg" "pwr" "w")
SAMPLES=("s0" "s1" "s3" "s4")

BASE_URL="https://raw.githubusercontent.com/luizafperin/MUSIC-EOS-data/refs/heads/main/EOS-gp/constrained/l${L}_s${S}"

# Use relative path (assumes script runs inside EOS_database)
TARGET_DIR="EOS-gp/constrained/l${L}_s${S}"
mkdir -p "${TARGET_DIR}"

for eos in "${EOS_TYPES[@]}"; do
  for sample in "${SAMPLES[@]}"; do

    FILE="eos_${eos}_${sample}_l${L}_s${S}.dat"
    URL="${BASE_URL}/${FILE}"
    DEST="${TARGET_DIR}/${FILE}"

    if [ -f "${DEST}" ]; then
      echo "Skipping ${FILE} (already exists)"
      continue
    fi

    echo "Downloading ${FILE}..."

    curl -fL -o "${DEST}" "${URL}"

  done
done
