{ inputs, ... }:
inputs.std-ext.common.lib.callFlake ./lock {
  sops-nix.inputs.nixpkgs = "nixos";
  ragenix.inputs.nixpkgs = "nixos";
  nixpkgs.locked = inputs.latest.sourceInfo;
  nixos.locked =
    inputs.nixos-22-11.sourceInfo
    // {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
    };
}
