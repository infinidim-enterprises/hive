{ lib, pkgs, ... }:
with lib;
mkMerge [{
  # home.file."bin/graphql-lsp".source = "${pkgs.graphql-language-service-cli}/bin/graphql-lsp";
  home.packages = [ pkgs.graphql-language-service-cli ];
}]
