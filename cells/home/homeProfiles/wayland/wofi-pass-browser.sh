#!/usr/bin/env bash

_log() {
  local msg time
  msg="${1}"
  time="${2:-10}"

  hyprctl notify 1 $((time * 1000)) 0 "wofi-pass-browser: ${msg}"
}

main() {
  local class title url domain
  local -a wofi

  wofi=("wofi-pass")
  read -r class title < <(hyprctl -j activewindow | jq -r '[.class, .title] | @tsv')

  # _log "XDG_DATA_HOME=${XDG_DATA_HOME}"
  # _log "class=${class}"
  # _log "title=${title}"

  if [[ ${class,,} == "chromium-browser" ]]; then
    # _log "found ${class}"

    if [[ $title == *" ::: "* ]]; then
      url=${title#* ::: }
      url=${url%% ::: *}
      # _log "url=${url}"
    fi

    [[ -n ${url} ]] && domain=$(tldextract --json "${url}" | jq -r '.domain')
    [[ -n ${domain} ]] && wofi+=("${domain}") # _log "domain=${domain}"
  fi

  # _log "$(printf '%s ' "${wofi[@]}")"

  exec "${wofi[@]}"
}

main
