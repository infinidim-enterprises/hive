{ lib, sources, crystal, ... }:

crystal.buildCrystalPackage rec {
  inherit (sources.xxhash2mac) src pname version;
  shardsFile = "${src}/shards.nix";
  format = "shards";
  doCheck = false;
  doInstallCheck = false;
}
