{ inputs
, cell
, ...
}:
let
  lib = inputs.nixpkgs-lib.lib // builtins;
  hosts = cell.nixosConfigurations;

  inherit (inputs) haumea nixpkgs;
  inherit (lib) mapAttrs recursiveUpdate filterAttrs;

  overrides = {
    depsos = { deployment.targetPort = 2265; };
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
            targetUser = "truelecter";
          };
        }
        (
          if overrides ? "${name}"
          then overrides."${name}"
          else { }
        )
    )
  )
  (filterAttrs (n: _: n != "octoprint") hosts)
