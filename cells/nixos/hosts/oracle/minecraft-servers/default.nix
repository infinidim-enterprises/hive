{
  imports = [
    ./dawncraft.nix
    ./e6e.nix
    ./sevtech.nix
  ];

  users = {
    groups = {
      minecraft-servers = { };
      minecraft-servers-backup = { };
    };
    users.truelecter.extraGroups = [ "minecraft-servers" ];
  };

  services.minecraft-servers = {
    eula = true;
    users.extraGroups = [ "minecraft-servers-backup" ];
  };
}
