{ inputs, cell, ... }:

{
  services.samba = {
    enable = true;
    nsswins = true;
    # syncPasswordsByPam = false;
    shares = {
      home = {
        "path" = "/persist/Jules/home/jules";
        "comment" = "Jules Backup";
        "force create mode" = 0600;
        "force directory mode" = 0700;
        "read only" = true;
        "valid users" = "vod";
      };
    };
    extraConfig = ''
      local master = no
    '';
  };

}
