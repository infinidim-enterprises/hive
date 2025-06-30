{ inputs, cell, ... }:
let
  lib = inputs.nixpkgs-lib.lib // builtins;
  inherit (lib) mapAttrs recursiveUpdate filterAttrs;

  overrides = {
    # asbleg-bootstrap = { deployment.targetHost = "192.168.1.135"; };
    asbleg = { deployment.targetHost = "asbleg.njk.local"; deployment.allowLocalDeployment = true; };
    marauder = { deployment.targetHost = "marauder.njk.local"; };
    oglaroon = { deployment.targetHost = "localhost"; deployment.allowLocalDeployment = true; };
    damogran = { deployment.targetHost = "damogran.njk.local"; }; # 192.168.1.133, damogran.njk.local
    kakrafoon = { deployment.targetHost = "kakrafoon.njk.local"; deployment.targetPort = 65522; };
  };
in
(mapAttrs
  (
    name: value:
    value
      // (
      recursiveUpdate
        {
          deployment = {
            targetHost = name;
            targetPort = 22;
            targetUser = "admin";
          };
        }
        (
          if overrides ? "${name}"
          then overrides."${name}"
          else { }
        )
    )
  )
  cell.nixosConfigurations)
#   // {
#   marauder-test = { nodes, ... }: {
#     inherit (cell.nixosConfigurations.marauder) bee imports;
#     environment.systemPackages = [ nodes.nixos-asbleg.config.system.build.toplevel ];
#     # imports = [ nodes.marauder.config ];
#   };
# }

#  (filterAttrs (n: _: n != "some_rpi_host") cell.nixosConfigurations)
