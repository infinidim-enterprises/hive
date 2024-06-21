{ inputs, cell, ... }:
let
  lib = inputs.nixpkgs-lib.lib // builtins;
  inherit (lib) mapAttrs recursiveUpdate filterAttrs;

  overrides = {
    asbleg-bootstrap = { deployment.targetHost = "192.168.1.133"; };
    asbleg = { deployment.targetHost = "192.168.1.133"; deployment.allowLocalDeployment = true; };
    marauder = { nodes, ... }: { deployment.targetHost = "192.168.1.129"; };
  };
in
mapAttrs
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
  cell.nixosConfigurations
#  (filterAttrs (n: _: n != "some_rpi_host") cell.nixosConfigurations)
