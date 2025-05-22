{ inputs, cell, ... }:

final: prev:
let
  flake = cell.lib.callFlake final.sources.shell.atuin.src;
  version = prev.lib.removePrefix "v" final.sources.shell.atuin.version;
  atuin = flake.packages.${prev.system}.default.overrideAttrs
    (_: { inherit version; });
in
{ inherit atuin; }
