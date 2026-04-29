#!/usr/bin/env bash
# Luiza Perin — Automated MUSIC run for multiple EOS files

# === Configuration ===
MUSIC_DIR="/home/luizaperin/MUSIC"

EOS_MODE="constrained"  # or "constrained"
EOS_BASE="$MUSIC_DIR/EOS/EOS-gp/$EOS_MODE"

RESULTS_BASE="/home/luizaperin/masters_research/hydro_res_analysis_newMUSIC"

# EOS parameters
L="400"
S="15"
EOS_TYPES=("w" "hrg" "pwr")
SAMPLES=("s")

# Path to the cpp file containing the EOS file definition
EOS_CPP_FILE="$MUSIC_DIR/src/eos_gp.cpp"

# MUSIC run command
MUSIC_BIN="$MUSIC_DIR/build/src/MUSIChydro"
MUSIC_INPUT="$MUSIC_DIR/example_inputfiles/test/music_input_mode_2"

# === Script ===
cd "$MUSIC_DIR" || exit 1

for eos_type in "${EOS_TYPES[@]}"; do
    for sample in "${SAMPLES[@]}"; do
        echo "-------------------------------------------------------"
        echo ">>> Running MUSIC for EOS: $eos_type | Sample: $sample"
        echo "-------------------------------------------------------"

        # Construct the EOS file path
        EOS_FILE="$EOS_BASE/l${L}_s${S}/eos_${eos_type}_${sample}_l${L}_s${S}.dat"

        # Sanity check
        if [[ ! -f "$EOS_FILE" ]]; then
            echo "ERROR: EOS file not found: $EOS_FILE"
            continue
        fi

	# === Update EOS file path in the C++ source ===
	echo "Updating EOS path in $EOS_CPP_FILE..."
	sed -i -E \
    	"s|std::ifstream eos_file\\(envPath .*|std::ifstream eos_file(envPath + \"/EOS/EOS-gp/$EOS_MODE/l${L}_s${S}/eos_${eos_type}_${sample}_l${L}_s${S}.dat\");|" \
    	"$EOS_CPP_FILE"

	sed -i -E \
    	"s|music_message << \"file from path .*|music_message << \"file from path \" << envPath.c_str() << \"/EOS/EOS-gp/$EOS_MODE/l${L}_s${S}/eos_${eos_type}_${sample}_l${L}_s${S}.dat \\\\n\";|" \
    	"$EOS_CPP_FILE"


	#compiling MUSIC
        echo "Compiling MUSIC..."
        cd "$MUSIC_DIR/build" || exit 1
        make -j || { echo "Compilation failed!"; exit 1; }
        
        cd "/home/luizaperin/MUSIC_repo"
        # === Run MUSIC ===
        LOG_FILE="${RESULTS_BASE}/res_${eos_type}/l${L}_s${S}/${sample}_l${L}_s${S}/${sample}_l${L}_s${S}.log"
        #LOG_FILE="${RESULTS_BASE}/res_tests/w_ValidSamples/${sample}_l${L}_s${S}.log"

        echo "Running MUSIC..."
        "$MUSIC_BIN" "$MUSIC_INPUT" > "$LOG_FILE" 2>&1

        # Prepare destination folder
        DEST_DIR="${RESULTS_BASE}/res_${eos_type}/l${L}_s${S}/${sample}_l${L}_s${S}"
        mkdir -p "$DEST_DIR"

        # Move important output files
        #if [[ -f surface_eps_0.18.dat ]]; then
           # mv surface_eps_0.18.dat "$DEST_DIR/"
        #fi
        if [[ -f evolution_xyeta.dat ]]; then
            mv evolution_xyeta.dat "$DEST_DIR/"
        fi

        echo "Run completed. Results stored in: $DEST_DIR"
        echo
    done
done

echo "✅ All EOS runs completed successfully!"

