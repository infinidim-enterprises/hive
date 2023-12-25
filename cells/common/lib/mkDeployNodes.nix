{ lib, ... }:
let
  inherit (lib) recursiveUpdate mapAttrs;

  mkDeployNodes = {
    __functor = _self: hosts: extraConfig:
      let
        getFqdn = c:
          let
            net = c.config.networking;
            fqdn =
              if net.domain != null
              then "${net.hostName}.${net.domain}"
              else net.hostName;
          in
          fqdn;
      in
      recursiveUpdate
        (mapAttrs
          (
            _: host:
              let
                activate = lib.deploy.${host.config.nixpkgs.system}.activate;
                hmProfiles =
                  mapAttrs
                    (n: v: {
                      user = n;
                      # profilePath = "/nix/var/nix/profiles/per-user/${n}/home-manager";
                      path = activate.home-manager v.home;
                    })
                    host.config.home-manager.users;
              in
              {
                hostname = getFqdn host;
                profilesOrder = (builtins.attrNames hmProfiles) ++ [ "system" ];
                profiles =
                  {
                    system = {
                      user = "root";
                      path = activate.nixos host;
                    };
                  }
                  // hmProfiles;
              }
          )
          hosts)
        extraConfig;

    doc = ''
      Synopsis: mkNodes _nixosConfigurations_

      Generate the `nodes` attribute expected by deploy-rs
      where _nixosConfigurations_ are `nodes`.
      This also inlcudes home-manager configurations

      Example input:
      {
        hostname-1 = { fastConnection = true; sshOpts = [ "-p" "25" ]; };
        hostname-2 = { sshOpts = [ "-p" "19999" ]; sshUser = "root"; };
      }
    '';
  };
in
mkDeployNodes
