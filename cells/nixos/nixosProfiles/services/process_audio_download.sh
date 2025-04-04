set -eo pipefail
shopt -s nullglob nocaseglob

trap "exit 0" EXIT INT TERM

# Configuration
THREADS=$(($(nproc) > 1 ? $(nproc) / 2 : 1))
BITRATE="128k"
SAMPLE_RATE="44100"
TARGET_CODEC="mp3"

ffmpeg_cmd=("ffmpeg" "-threads" "$THREADS" "-hide_banner" "-loglevel" "error" "-y")

build_find_pattern() {
  local -n arr=$1
  local exts=("flac" "ogg" "mp3" "ape" "wav" "m4a" "aac")
  arr=(-type f)
  arr+=("(")
  local first=true
  for ext in "${exts[@]}"; do
    if "$first"; then
      first=false
    else
      arr+=(-o)
    fi
    arr+=(-iname "*.$ext")
  done
  arr+=(")")
}

has_audio_files() {
  local dir="$1"
  local -a find_pattern
  build_find_pattern find_pattern
  find "$dir" "${find_pattern[@]}" -print -quit | grep -q .
}

convert_compliant_wav() {
  "${ffmpeg_cmd[@]}" -i "$1" -ar 44100 -ac 2 -c:a pcm_s16le "$2"
}

validate_mp3() {
  local input="$1"
  ffprobe -v error \
    -select_streams a:0 \
    -show_entries stream=codec_name,sample_rate,bit_rate \
    -of json "$input" |
    jq -e \
      --arg codec "$TARGET_CODEC" \
      --arg rate "$SAMPLE_RATE" \
      --arg br "$BITRATE" \
      '(.streams[0] | {codec_name, sample_rate, bit_rate}) ==
       {codec_name: $codec, sample_rate: $rate, bit_rate: ($br | sub("k$"; "000"))}'
}

process_single_track() {
  local input="$1"
  local extension="${input##*.}"
  local dir temp_file
  dir="$(dirname "$input")"

  if [[ ${extension,,} == "$TARGET_CODEC" ]]; then
    if validate_mp3 "$input"; then
      return
    fi
    temp_file="$(mktemp -u -p "$dir" "$(basename "${input%.*}-temp.XXXXXX.$extension")")"
  else
    temp_file="$(mktemp -u -p "$dir" "$(basename "${input%.*}.XXXXXX.$TARGET_CODEC")")"
  fi

  echo "Converting (-> mp3): $(basename "$input")"
  if "${ffmpeg_cmd[@]}" -i "$input" \
    -b:a "$BITRATE" \
    -ar "$SAMPLE_RATE" \
    -map_metadata 0 \
    -id3v2_version 3 \
    -write_id3v1 1 \
    -c:a "$TARGET_CODEC" \
    "$temp_file"; then

    if [[ ${extension,,} != "$TARGET_CODEC" ]]; then
      rm -f "$input"
    fi
    mv -f "$temp_file" "${input%.*}.$TARGET_CODEC"
  else
    echo "Error converting $input" >&2
    rm -f "$temp_file"
    return 1
  fi
}

get_audio_from_cue() {
  local cue_file="$1"
  grep -m1 -E 'FILE\s+"[^"]+"\s+' "$cue_file" |
    sed -E 's/.*FILE\s+"([^"]+)".*/\1/i' |
    tr -d '\r'
}

process_cue_image() {
  local cue_file="$1"
  local dir base audio_file
  dir="$(dirname "$cue_file")"
  base="$(basename "$cue_file" .cue)"

  audio_file="$dir/$(get_audio_from_cue "$cue_file")"
  # TODO: use the declared audio_file from the CUE, don't try to find it.
  [ -f "$audio_file" ] || {
    local -a find_pattern
    build_find_pattern find_pattern
    audio_file="$(find "$dir" -maxdepth 1 "${find_pattern[@]}" -print -quit)"
  }

  if [ -z "$audio_file" ] || [ ! -f "$audio_file" ]; then
    echo "Audio file not found for $cue_file" >&2
    return 1
  fi

  local temp_wav
  temp_wav="$(mktemp -u -p "$dir" "${base}-temp.XXXXXX.wav")"
  if ! shntool info -w -q "$audio_file" &>/dev/null; then
    echo "Converting (-> wav): $(basename "$audio_file")"
    convert_compliant_wav "$audio_file" "$temp_wav"
  else
    cp "$audio_file" "$temp_wav"
  fi

  if shntool split -q -w -f "$cue_file" -d "$dir" -t '%p - %a - %n - %t' "$temp_wav"; then
    rm -f "$temp_wav" "$audio_file" "$cue_file"
    rm -f "${dir}"/*pregap.*
    local -a find_pattern tracks
    build_find_pattern find_pattern

    readarray -d '' tracks < <(find "$dir" "${find_pattern[@]}" -print0)
    for track in "${tracks[@]}"; do
      process_single_track "$track"
    done
  else
    echo "Error splitting $audio_file" >&2
    rm -f "$temp_wav"
    return 1
  fi
}

process_directory() {
  local dir cue_files tracks subdirs
  local -a find_pattern
  dir="$1"

  build_find_pattern find_pattern

  # Process current directory first
  mapfile -t cue_files < <(find "$dir" -maxdepth 1 -type f -iname "*.cue" -print)
  if ((${#cue_files[@]} > 0)); then
    for cue in "${cue_files[@]}"; do
      echo "Found: $cue"
      process_cue_image "$cue"
      echo "Done: $cue"
    done
  else
    echo "Not found: cue file in ${dir}"

    # Process audio files in current directory
    readarray -d '' tracks < <(find "$dir" -maxdepth 1 "${find_pattern[@]}" -print0)
    if ((${#tracks[@]} > 0)); then
      echo "Has tracks: $dir"
      for track in "${tracks[@]}"; do
        echo "Found: $track"
        process_single_track "$track"
        echo "Done: $track"
      done
    fi
  fi

  # Recursively process subdirectories
  readarray -d '' subdirs < <(find "$dir" -mindepth 1 -type d -print0)
  for subdir in "${subdirs[@]}"; do
    process_directory "$subdir"
  done
}

f_lock() {
  local timeout dir
  timeout="$1"
  dir="$2"

  lock_file="/tmp/process_audio_download.lock"
  exec 200>"$lock_file"

  echo "Waiting to acquire lock for $dir"
  while true; do
    # Try to acquire lock with 10 second timeout
    if flock -w "$timeout" -e 200; then
      echo "Lock acquired for $dir"
      echo "lock_file: $(realpath "$lock_file")"
      break
    else
      echo "Still waiting to acquire lock for $dir ..."
    fi
  done
}

main() {
  local input_dir lock_file tag_dir

  input_dir="${1:-${TR_TORRENT_DIR:+${TR_TORRENT_DIR}/${TR_TORRENT_NAME}}}"

  if [ -z "$input_dir" ]; then
    echo "No input directory specified" >&2
    exit 1
  fi

  if [ -d "$input_dir" ] && has_audio_files "$input_dir"; then
    f_lock "120" "$(realpath "$input_dir")"
    echo "Processing: $(realpath "$input_dir")"
    process_directory "$input_dir"

    tag_dir="$(dirname "$input_dir")"

    if [[ -v TR_TORRENT_NAME ]] && [ "$(basename "$tag_dir")" = "lidarr" ]; then
      echo "Moving $TR_TORRENT_NAME to ${tag_dir}/done"
      mkdir -p "${tag_dir}/done"
      mv -f "$input_dir" "${tag_dir}/done"
    fi

  else
    echo "No audio files found in $input_dir" >&2
  fi
}

main "$@"
