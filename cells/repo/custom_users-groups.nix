# TODO: inputs.cells.repo.custom_users-groups
{ inputs, cell, ... }:

let
  pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
  moddedUserModule =
    with inputs.nixpkgs-lib.lib;
    pkgs.runCommandNoCC "patched_users-groups.nix"
      {
        buildInputs = with pkgs; [ gnused nixpkgs-fmt ];
        passAsFile = [ "oldmod" ];
        oldmod = fileContents "${pkgs.path}/nixos/modules/config/users-groups.nix";
      } ''
      # remove first and last lines
      sed '1d; $d' ${../nixosModules/_extraUserOpts.nix} > extraUserOpts.nix

      # patch the userOpts
      sed '/userOpts/,/options = {/!b;/options = {/r extraUserOpts.nix' \
      $oldmodPath | nixpkgs-fmt > $out
    '';
in

{ lib, pkgs, modulesPath, ... }:
{
  # config.system.build.newmod = moddedUserModule;
  disabledModules = [ "${modulesPath}/config/users-groups.nix" ];
  imports = [ moddedUserModule.outPath ];
}
