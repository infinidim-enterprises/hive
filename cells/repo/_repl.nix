{ flakePath }:
let
  compatFlake =
    if builtins.pathExists flakePath
    then
      (import
        (
          let
            lock = builtins.fromJSON (builtins.readFile ((builtins.getEnv "PRJ_ROOT") + ./flake.lock));
          in
          fetchTarball {
            url = lock.nodes.flake-compat.locked.url or "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
            sha256 = lock.nodes.flake-compat.locked.narHash;
          }
        )
        { src = toString flakePath; }).defaultNix
    else { };

  lib = Flake.inputs.nixpkgs-lib.lib;

  Channels =
    lib.genAttrs [
      "nixpkgs"
      "nixpkgs-unstable"
      "nixpkgs-master"
    ]
      (x: Flake.inputs.${x} // { pkgs = Flake.inputs.${x}.legacyPackages.${builtins.currentSystem}; });

  Flake = builtins.getFlake (toString flakePath);

  Lib = with lib; let
    inputsWithLibs = filterAttrs (n: v: v ? lib && !elem n (attrNames Channels)) Flake.inputs;
    cellsWithLibs = mapAttrs (_: v: v.lib) (filterAttrs (n: v: v ? lib && v.lib != { }) Flake.${builtins.currentSystem});
  in
  (mapAttrs (_: v: v.lib) (Channels // inputsWithLibs)) // { cells = cellsWithLibs; };

  stdLib = lib // builtins;

  Legacy = with stdLib; let
    path = toPath ((getEnv "PRJ_ROOT") + "/../legacy/systems");
  in
  if pathExists path
  then getFlake path
  else null;

  OldHive = with stdLib; let
    path = toPath ((getEnv "PRJ_ROOT") + "/../hive");
  in
  if pathExists path
  then getFlake path
  else null;

  Cells = Flake.${builtins.currentSystem};
  # TODO: Me = with stdLib; let hostName = readFile /etc/hostname; in hostName;
in
{
  inherit
    Cells
    Channels
    Flake
    # LoadFlake

    Lib
    Legacy
    OldHive
    ;
} // lib
