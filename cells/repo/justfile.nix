{ inputs, cell, ... }:

{
  generate = {
    args = [ "format-path" "name" ];
    description = "nixos-generators with custom format";
    # awk -F ' ' '{print $3}'
    content = ''
      nixos-generate --format-path ''${PRJ_ROOT}/cells/nixos/generators/{{format-path}}.nix --system x86_64-linux --flake .#{{name}}
    '';
  };

  machine = {
    args = [ "action" "name" ];
    description = "Colmena [action] [name] Machine";
    content = ''
      colmena {{action}} --on {{name}}
    '';
  };
}
