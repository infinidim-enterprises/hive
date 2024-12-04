{ pkgs, lib, config, self, name, ... }:
###
# TODO: https://github.com/Gopiandcode/.nyxt.d
# https://github.com/RaitaroH/DarkWeb
# https://github.com/bqv/rc/blob/master/users/browsers/nyxt/default.nix
# https://github.com/aartaka/nyxt-config
let
  inherit (lib)
    mkIf
    mkMerge
    hasPrefix
    filterAttrs
    removePrefix
    mapAttrsToList;
  linkConfig = with builtins; pathExists "${self}/users/${name}/dotfiles/nyxt.d";
  nyxt-extensions = pkgs.linkFarm "nyxt-ext"
    (mapAttrsToList (k: v: { name = (removePrefix "nyxt-ext_" k); path = v.src; })
      (filterAttrs (k: v: hasPrefix "nyxt-ext_" k) pkgs.sources-emacs));
in
mkMerge [
  { home.packages = [ pkgs.nyxt ]; }

  (mkIf config.xdg.enable {
    xdg.dataFile."nyxt/extensions".source = nyxt-extensions;
  })

  (mkIf config.xdg.mimeApps.enable {
    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/http" = "nyxt.desktop";
      "x-scheme-handler/https" = "nyxt.desktop";
    };
  })
]
