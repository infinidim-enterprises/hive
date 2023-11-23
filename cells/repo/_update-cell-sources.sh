updateSources() {
  local src_dir
  local toml

  src_dir=$(dirname "${1}")
  toml="${1}"

  nvfetcher -j 0 -t -o "${src_dir}" -c "${toml}"
}

updateSourcesFirefoxAddons() {
  local tmpdir
  local in_file
  local src_dir
  local out_file
  local pkgs_file
  local final_nix

  tmpdir=$(mktemp -d nvfetcher-ff-addons.XXXXXXXX --tmpdir)
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
  # cat "${pkgs_file}" | alejandra --quiet >> "${final_nix}"
  alejandra --quiet <"${pkgs_file}" >>"${final_nix}"

  rm -rf "${tmpdir}"
}

regularOrFirefox() {
  local src="${1}"
  if [[ ${src} =~ "firefox" ]]; then
    updateSourcesFirefoxAddons "${src}"
  else
    updateSources "${src}"
  fi
}

updateSourcesAll() {
  shopt -s globstar nullglob
  for src in "${PRJ_ROOT}"/**/nvfetcher.toml; do
    regularOrFirefox "${src}"
  done
  shopt -u globstar nullglob
}

updateSourcesForCell() {
  shopt -s globstar nullglob
  local cell="${1}"
  for src in "${PRJ_ROOT}"/cells/"${cell}"/**/nvfetcher.toml; do
    regularOrFirefox "${src}"
  done
  shopt -u globstar nullglob
}

if [[ ${1} == "ALL" ]]; then
  updateSourcesAll
else
  updateSourcesForCell "${1}"
fi
