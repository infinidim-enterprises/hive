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

  release = {
    description = "gh-actions keygen.iso";
    # awk -F ' ' '{print $3}'
    content = ''
      nixos-generate --format-path ''${PRJ_ROOT}/cells/nixos/generators/installer.nix --system x86_64-linux --flake .#nixos-marauder > /tmp/output.txt
    '';
  };

  # vm = {
  #   args = [ "name" ];
  #   description = "Start microvm [name]";
  #   content = ''
  #     rm -rf /tmp/nix-store-overlay.img
  #     std //nixos/microvms/{{name}}:run
  #   '';
  # };
}
