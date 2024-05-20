{ inputs
, cell
, ...
}:
let
  lib = inputs.nixpkgs-lib.lib // builtins;
  # hosts = cell.nixosConfigurations;

  # inherit (inputs) haumea nixpkgs;
  inherit (lib) mapAttrs recursiveUpdate filterAttrs;

  overrides = {
    asbleg-bootstrap = { deployment.targetHost = "192.168.1.133"; };
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
  (filterAttrs (n: _: n != "octoprint") cell.nixosConfigurations)
