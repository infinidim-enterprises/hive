# shellcheck disable=SC2046
set -x
trap "exit 0" EXIT

THREADS=$(($(nproc) > 1 ? $(nproc) / 2 : 1))

ffmpeg_cmd=("ffmpeg" "-threads" "$THREADS" "-hide_banner" "-loglevel" "error")

file_pattern() {
  local fname last_index
  local -a audio_extensions pattern

  fname="$1"
  audio_extensions=("flac" "ogg" "mp3" "ape" "wav")
  pattern=()
  last_index=$((${#audio_extensions[@]} - 1))

  for ((i = 0; i < ${#audio_extensions[@]}; i++)); do
    pattern+=("-iname " "'${fname}.${audio_extensions[i]}'")
    if [[ $i -lt $last_index ]]; then
      pattern+=(" -o ")
    fi
  done
  # echo "${pattern[@]}"
  printf "%s" "${pattern[@]}"
}

has_audio_files() {
  local dir
  dir="$1"

  if find "$dir" -type f \( $(file_pattern '*') \) -print | grep -q .; then
    return 0
  else
    return 1
  fi
}

convert_compliant_wav() {
  local input output

  input="$1"
  output="$2"

  "${ffmpeg_cmd[@]}" -i "$input" -ar 44100 -ac 2 -c:a pcm_s16le "$output"
}

process_single_track() {
  local input extension dir result temp_file

  input="$1"
  extension="${input##*.}"
  dir="$(dirname "$input")"

  if [[ $extension == "mp3" ]]; then
    result=$(ffprobe -v error \
      -select_streams a:0 \
      -show_entries stream=codec_name,sample_rate,bit_rate \
      -of json "$input" |
      jq -r '(.streams[0] | {codec_name, sample_rate, bit_rate}) == {"codec_name": "mp3", "sample_rate": "44100", "bit_rate": "128000"}')
    if [[ $result == "true" ]]; then
      echo "$(basename "$input") needs no conversion"
      return
    else
      echo "$(basename "$input") needs conversion"
      temp_file="$dir/$(basename "${input%.*}")-temp.${extension}"
    fi
  else
    echo "$(basename "$input") needs conversion"
    temp_file="$dir/$(basename "${input%.*}").mp3"
  fi

  echo "Will convert $(basename "$input") ->  $(basename "$temp_file")"

  if "${ffmpeg_cmd[@]}" \
    -i "$input" \
    -b:a 128k \
    -ar 44100 \
    -map_metadata 0 \
    -id3v2_version 3 \
    -write_id3v1 1 \
    "$temp_file"; then
    echo "Converted $(basename "$input") ->  $(basename "$temp_file")"
    if [[ $extension != "mp3" ]]; then
      rm -f "$input"
    else
      mv -f "$temp_file" "$input"
    fi
  else
    echo "Error converting $(basename "$input") ->  $(basename "$temp_file")"
  fi
}

process_cue_image() {
  local cue_file dir base temp_wav audio_file
  local -a tracks

  cue_file="$1"
  dir="$2"
  base=$(basename "${cue_file%.*}")
  temp_wav="${dir}/${base}-temp.wav"
  audio_file=$(find "$dir" -maxdepth 1 -type f \( $(file_pattern "${base}") \) -print -quit)

  if [[ ! -f $audio_file ]]; then
    echo "Not found: $audio_file" && exit 1
  fi

  if shntool info "$audio_file" &>/dev/null; then
    temp_wav="$audio_file"
  else
    convert_compliant_wav "$audio_file" "$temp_wav"
  fi

  if shntool split \
    -f "$cue_file" \
    -d "$dir" \
    -t '%p - %a - %n - %t' \
    "$temp_wav"; then
    if [[ $temp_wav != "$audio_file" ]]; then
      rm -f "$temp_wav"
    fi
    rm -f "$audio_file"
    rm -f "$cue_file"
    readarray -d '' tracks < <(find "$dir" -type f \( $(file_pattern '*') \) -print0)
    for track in "${tracks[@]}"; do
      process_single_track "$track"
    done
  fi
}

process_directory() {
  local dir
  local -a audio_files cue_files

  dir="$1"

  readarray -d '' audio_files < <(find "$dir" -type f \( $(file_pattern '*') \) -print0)
  readarray -d '' cue_files < <(find "$dir" -type f -iname "*.cue" -print0)

  if [[ ${#cue_files[@]} -eq 0 ]]; then
    echo "Not found: CUE file(s)"
    if [[ ${#audio_files[@]} -eq 0 ]]; then
      echo "Not found: audio file(s)"
      exit 0
    else
      for audio in "${audio_files[@]}"; do
        process_single_track "$audio"
      done
    fi
  else
    for cue in "${cue_files[@]}"; do
      process_cue_image "$cue" "$(dirname "$cue")"
    done
  fi
}

main() {
  local input_dir

  if [[ $# -eq 0 ]]; then
    if [[ -z ${TR_TORRENT_DIR:-} || -z ${TR_TORRENT_NAME:-} ]]; then
      echo "No arguments provided to the script. Exiting..."
      exit 0
    fi
    input_dir="${TR_TORRENT_DIR}/${TR_TORRENT_NAME}"
  elif [[ $# -eq 1 ]]; then
    input_dir="$1"
  else
    exit 0
  fi

  if [[ -d $input_dir ]] && has_audio_files "$input_dir"; then
    process_directory "$input_dir"
  fi

}

main "$@"
