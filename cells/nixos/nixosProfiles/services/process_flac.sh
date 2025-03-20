# Function to split a FLAC file into individual tracks
split_flac() {
  local flac_file="$1"
  local cue_file="${flac_file%.flac}.cue"

  echo "Splitting '$flac_file' using '$cue_file'..."
  if shnsplit -f "$cue_file" -t "%n - %t" -o flac "$flac_file"; then
    echo "Successfully split '$flac_file'."
    for pregap in *pregap.flac; do
      if [ -e "$pregap" ]; then
        echo "Found pregap file '$pregap', deleting..."
        rm "$pregap"
      fi
    done

    rm "$flac_file"
    rm "$cue_file"
    echo "Removed original FLAC,CUE files: '$flac_file', '$cue_file'."
    return 0
  else
    echo "Failed to split '$flac_file'. Check if the CUE file is valid."
    return 1
  fi
}

convert_to_mp3() {
  local flac_file="$1"

  # Determine total number of cores and calculate half (ensuring at least 1 thread)
  local total_cores
  total_cores=$(nproc)
  local threads=$((total_cores / 2))
  if [ "$threads" -lt 1 ]; then
    threads=1
  fi

  # Use the calculated thread count for the ffmpeg conversion
  if ffmpeg -threads "$threads" -i "$flac_file" -b:a 128k -map_metadata 0 -id3v2_version 3 "${flac_file%.flac}.mp3"; then
    echo "Converted '$flac_file' to MP3 using $threads threads."
    rm "$flac_file"
  else
    echo "Failed to convert '$flac_file' to MP3."
  fi
}

# Function to process the input directory
process_directory() {
  local input_dir="$1"

  if ! cd "$input_dir"; then
    echo "Directory not found: $input_dir"
    exit 0
  fi

  # Check if there is exactly one FLAC file and a corresponding CUE file
  local flac_files=(*.flac)
  local flac_file="${flac_files[0]}"
  local cue_file="${flac_file%.flac}.cue"

  if [[ ${#flac_files[@]} -ne 1 || ! -f $cue_file ]]; then
    echo "Directory does not contain exactly one FLAC file or no corresponding CUE file found. Exiting gracefully."
    exit 0
  fi

  # Split the FLAC file
  if split_flac "$flac_file"; then
    echo "Successfully split $flac_file into tracks."
    for split_flac_file in *.flac; do
      convert_to_mp3 "$split_flac_file"
    done
  else
    echo "Processing failed."
  fi
}

# Main script execution
main() {
  local input_dir

  if [[ $# -eq 0 ]]; then
    if [[ -z $TR_TORRENT_DIR || -z $TR_TORRENT_NAME ]]; then
      echo "Error: Must provide input directory or set Transmission variables." >&2
      exit 1
    fi
    input_dir="$TR_TORRENT_DIR/$TR_TORRENT_NAME"
  elif [[ $# -eq 1 ]]; then
    input_dir="$1"
  else
    echo "Usage: $0 /path/to/your/music/collection"
    exit 1
  fi

  echo '----------'
  echo "input_dir: $input_dir"
  echo '----------'

  process_directory "$input_dir"
}

# Invoke the main function with all script arguments
main "$@"
