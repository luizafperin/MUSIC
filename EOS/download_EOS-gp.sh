MODE=("constrained" "unconstrained" "training")
EOS_TYPES=("hrg" "pwr" "w")
SAMPLES=("s0" "s1" "s2" "s3" "s4" "s5" "s6" "s7" "s8" "s9" "s10" "s11" "s12" 
"s13" "s14" "s15" "s16" "s17" "s18" "s19")
T=(136 150)

L_VALUES=(400)
SIGMA_VALUES=(15)

for mode in "${MODE[@]}"; do
  for temp in "${T[@]}"; do
    for L in "${L_VALUES[@]}"; do
      for SIGMA in "${SIGMA_VALUES[@]}"; do

        BASE_URL="https://raw.githubusercontent.com/luizafperin/MUSIC-EOS-data/refs/heads/main/EOS-gp/Tsw_${temp}/${mode}/l${L}_s${SIGMA}"
        TARGET_DIR="EOS-gp/Tsw_${temp}/${mode}/l${L}_s${SIGMA}"

        mkdir -p "${TARGET_DIR}"

        for eos in "${EOS_TYPES[@]}"; do
          for sample in "${SAMPLES[@]}"; do
            FILE="eos_${eos}_${sample}_l${L}_s${SIGMA}.dat"
            URL="${BASE_URL}/${FILE}"
            DEST="${TARGET_DIR}/${FILE}"

            if [ -f "${DEST}" ]; then
              echo "Skipping ${FILE} (already exists)"
              continue
            fi

            echo "Downloading ${FILE}..."
            curl -fL -o "${DEST}" "${URL}" || {
            	echo "Warning: ${FILE} not found, skipping."
    		rm -f "${DEST}"
            } 
          done
        done

      done
    done
  done
done
