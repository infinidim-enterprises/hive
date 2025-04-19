{ pkgs, ... }:

{
  home.packages = with pkgs; [
    yarn2nix
    emmet-ls
    css-checker
  ];
}
