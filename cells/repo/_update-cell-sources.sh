version_at_least() {
  local version_input
  local version_min
  local version_clean

  version_input=$1
  version_min=$2

  version_clean=$(echo "$version_input" | grep -oP '\d+(\.\d+)+')

  IFS='.' read -r -a version_array <<<"$version_clean"
  IFS='.' read -r -a min_array <<<"$version_min"

  for i in "${!min_array[@]}"; do
    local version_part=${version_array[$i]:-0} # Default to 0 if part is missing
    local min_part=${min_array[$i]}

    if ((version_part > min_part)); then
      return 0 # True, version is greater
    elif ((version_part < min_part)); then
      return 1 # False, version is smaller
    fi
  done

  return 0
}

createKeyfile() {
  local keyfile

  keyfile="${1}"

  echo '[keys]' >"${keyfile}"
  echo "github = \"${GITHUB_TOKEN}\"" >>"${keyfile}"
}

with_globstar() {
  shopt -s globstar nullglob
  "$@"
  shopt -u globstar nullglob
}

updateSources() {
  local src_dir
  local toml
  local nvfetcher_cmd
  local tmpdir
  local keyfile

  src_dir=$(dirname "${1}")
  toml="${1}"

  tmpdir=$(mktemp -d nvfetcher-keyfile.XXXXXXXX --tmpdir)
  trap 'rm -rf "${tmpdir:-}"' EXIT

  keyfile="${tmpdir}/keyfile.toml"

  nvfetcher_version=$(nvfetcher --version 2>&1 | grep -oP '\d+(\.\d+)+')

  nvfetcher_cmd="nvfetcher -j 0 --timing --build-dir ${src_dir} --config ${toml}"

  if version_at_least "${nvfetcher_version}" "0.7"; then
    nvfetcher_cmd="${nvfetcher_cmd} --keep-old"
  fi

  if [[ -n ${GITHUB_TOKEN} ]]; then
    createKeyfile "${keyfile}" && nvfetcher_cmd="${nvfetcher_cmd} --keyfile ${keyfile}"
  fi

  eval "${nvfetcher_cmd}"

  rm -rf "${tmpdir}"
}

updateSourcesFirefoxAddons() {
  local tmpdir
  local in_file
  local src_dir
  local out_file
  local pkgs_file
  local final_nix

  tmpdir=$(mktemp -d nvfetcher-ff-addons.XXXXXXXX --tmpdir)
  trap 'rm -rf "${tmpdir:-}"' EXIT

  in_file="${1}"
  src_dir=$(dirname "${1}")
  out_file="${tmpdir}"/sources.json
  pkgs_file="${tmpdir}"/generated-home-manager.nix
  final_nix="${src_dir}"/generated.nix

  remarshal -i "${in_file}" -o "${out_file}" --unwrap addons
  mozilla-addons-to-nix "${out_file}" "${pkgs_file}"

  sed -i 's/buildFirefoxXpiAddon /rec /g' "${pkgs_file}"
  sed -i '1d' "${pkgs_file}"
  echo '{ lib, ... }:' >"${final_nix}"
  nixpkgs-fmt <"${pkgs_file}" >>"${final_nix}"

  rm -rf "${tmpdir}"
}

regularOrFirefox() {
  local src

  src="${1}"

  if [[ ${src} =~ "firefox" ]]; then
    updateSourcesFirefoxAddons "${src}"
  else
    updateSources "${src}"
  fi
}

_updateSourcesAll() {
  for src in "${PRJ_ROOT}"/**/nvfetcher.toml; do
    regularOrFirefox "${src}"
  done
}

_updateSourcesForCell() {
  local input
  local cell
  local subdir
  local search_path

  input="${1}"

  cell=$(echo "${input}" | cut -d '/' -f 1)
  subdir=$(echo "${input}" | cut -d '/' -f 2-)

  if [[ -z ${subdir} ]]; then
    search_path="${PRJ_ROOT}/cells/${cell}"
  else
    search_path="${PRJ_ROOT}/cells/${cell}/${subdir}"
  fi

  if [[ ! -d ${search_path} ]]; then
    echo "Error: Directory '${search_path}' does not exist."
    return 1
  fi

  for src in "${search_path}"/**/nvfetcher.toml; do
    regularOrFirefox "${src}"
  done
}

updateSourcesAll() {
  with_globstar _updateSourcesAll
}

updateSourcesForCell() {
  local cell
  cell="${1}"

  with_globstar _updateSourcesForCell "${cell}"
}

if [[ $# -eq 0 || ${1} == "ALL" ]]; then
  updateSourcesAll
else
  updateSourcesForCell "${1}"
fi
