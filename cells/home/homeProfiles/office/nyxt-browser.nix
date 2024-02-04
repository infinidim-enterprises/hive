{ pkgs, self, name, ... }:
###
# TODO: https://github.com/Gopiandcode/.nyxt.d
# https://github.com/RaitaroH/DarkWeb
# https://github.com/bqv/rc/blob/master/users/browsers/nyxt/default.nix
# https://github.com/aartaka/nyxt-config
let
  linkConfig = with builtins; pathExists "${self}/users/${name}/dotfiles/nyxt.d";
in
{ home.packages = [ pkgs.nyxt ]; }
