# Function to split a FLAC file into individual tracks
split_flac() {
  local flac_file="$1"
  local cue_file="${flac_file%.flac}.cue"

  if [[ -f $cue_file ]]; then
    shnsplit -f "$cue_file" -t "%n - %t" -o flac "$flac_file"
    if [[ $? -eq 0 ]]; then
      echo "Successfully split '$flac_file'."
      return 0
    else
      echo "Failed to split '$flac_file'."
      return 1
    fi
  else
    echo "No CUE file found for '$flac_file'. Skipping."
    return 1
  fi
}

# Function to apply tags from the CUE file to the split FLAC tracks
apply_tags() {
  local cue_file="$1"
  cuetag "$cue_file" split-track*.flac
}

# Function to re-encode a FLAC file to MP3 at 128 kbps
convert_to_mp3() {
  local flac_file="$1"
  ffmpeg -i "$flac_file" -b:a 128k "${flac_file%.flac}.mp3"
  if [[ $? -eq 0 ]]; then
    echo "Converted '$flac_file' to MP3."
    rm "$flac_file"
  else
    echo "Failed to convert '$flac_file' to MP3."
  fi
}

# Function to process all FLAC files in the specified directory
process_directory() {
  local input_dir="$1"
  cd "$input_dir" || {
    echo "Directory not found: $input_dir"
    exit 1
  }

  for flac_file in *.flac; do
    split_flac "$flac_file" && apply_tags "${flac_file%.flac}.cue"
    for split_flac in split-track*.flac; do
      convert_to_mp3 "$split_flac"
    done
    rm "$flac_file"
  done
}

# Main script execution
main() {
  local input_dir="$1"
  if [[ -z $input_dir ]]; then
    echo "Usage: $0 /path/to/your/music/collection"
    exit 1
  fi
  process_directory "$input_dir"
}

# Invoke the main function with all script arguments
main "$@"
