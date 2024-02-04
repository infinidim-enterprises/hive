{ config, lib, pkgs, ... }:
with lib;
mkMerge [
  {
    # LLVM_CONFIG=${llvm.dev}/bin/llvm-config
    home.sessionVariables.LLVM_CONFIG = "${pkgs.llvm.dev}/bin/llvm-config";

    home.packages = with pkgs; [
      crystal
      shards
      # icr
      # (scry.override { crystal = pkgs.crystal_1_2; })
      openssl.dev
      openssl
      pkg-config
      crystal2nix
    ];
  }

  (mkIf config.programs.vscode.enable
    {
      programs.vscode.userSettings."crystal-lang.completion" = true;
      programs.vscode.extensions = with pkgs.vscode-extensions; [
        crystal-lang
        crystal-spec-vscode
      ];
    }
  )

]
