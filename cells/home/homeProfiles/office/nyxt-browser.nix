{ pkgs, self, name, ... }:
###
# TODO: https://github.com/Gopiandcode/.nyxt.d
# https://github.com/RaitaroH/DarkWeb
# https://github.com/bqv/rc/blob/master/users/browsers/nyxt/default.nix
# https://github.com/aartaka/nyxt-config
let
  linkConfig = with builtins; pathExists "${self}/users/${name}/dotfiles/nyxt.d";
  # ~/.local/share/nyxt/extensions
  /*
    bootables = pkgs.linkFarm "bootable_images" (map
    (host: {
      name = "boot/${host}";
      path = getAttrFromPath [ host "config" "system" "build" "ipxeBootDir" ] self.nixosConfigurations;
    })
    (attrNames (filterAttrs (_: v: with v.config.deploy; (hasAttrByPath [ "lan" "ipxe" ] params) && params.lan.ipxe == true) self.nixosConfigurations)));

  */
in
{ home.packages = [ pkgs.nyxt ]; }
