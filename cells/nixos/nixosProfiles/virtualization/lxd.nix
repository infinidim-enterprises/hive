{ inputs, cell, ... }:

{
  virtualisation.lxd.enable = true;
  users.groups.lxd.members = [ ];
}
