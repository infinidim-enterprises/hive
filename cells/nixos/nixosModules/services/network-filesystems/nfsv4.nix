{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.nfsv4;
  nfs_template = {
    fsType = "nfs4";
    options = [
      "soft"
      "noauto"
      "_netdev"
      "timeo=5"
      "retrans=1"
      "x-systemd.automount"
      "x-systemd.idle-timeout=3min"
      "x-systemd.mount-timeout=5s"
    ];
  };
  exportsOptions = with types; { ... }: {
    options = { source = mkOption { type = str; }; target = mkOption { type = str; }; };
  };
in
{
  options.services.nfsv4 = with types; {
    server = {
      enable = mkEnableOption "nfsv4 compliant exports with fsid=0";
      root = mkOption { type = str; default = "/exports"; };
      exports = mkOption { type = attrsOf (submodule [ exportsOptions ]); };
    };
    client = {
      enable = mkEnableOption "nfsv4 compliant mounts with fsid=0";
      root = mkOption { type = str; default = "/mnt"; };
      mounts = mkOption {
        type = listOf str;
        default = [ ];
        apply = l: listToAttrs (map
          (device: nameValuePair
            (cfg.client.root + "/" + (head (splitString ":" device)) + "/" + (last (splitString "/" device)))
            (nfs_template // { inherit device; }))
          l);
      };
    };
  };

  config = mkMerge [

    # Server
    (mkIf cfg.server.enable {
      systemd.tmpfiles.rules = [ "d ${cfg.server.root} 0755 root root - -" ];
      services.rpcbind.enable = true;
      services.nfs.server.enable = true;
      services.nfs.server.extraNfsdConfig = ''
        UDP=on
        TCP=on
        vers2=off
        vers3=off
        vers4=on
        vers4.2=on
      '';
      # https://www.thegeekdiary.com/how-to-enable-nfs-debug-logging-using-rpcdebug/
      fileSystems = mapAttrs'
        (name: opts:
          nameValuePair
            "${cfg.server.root}/${name}"
            { device = opts.source; options = [ "rbind" ]; })
        (filterAttrs (k: v: !hasPrefix cfg.server.root v.source) cfg.server.exports);

      services.nfs.server.exports = mkBefore ''
        ${cfg.server.root} *(ro,sync,fsid=0,no_root_squash,no_subtree_check,no_all_squash)
        ${concatMapStringsSep "\n"
            (e: "${cfg.server.root}/${e}" + " " + cfg.server.exports."${e}".target)
          (attrNames cfg.server.exports)}
      '';

    })

    # Clients
    (mkIf cfg.client.enable {
      systemd.tmpfiles.rules = [ "d ${cfg.client.root} 0755 root root - -" ];
      fileSystems = cfg.client.mounts;
      networking.firewall.allowedTCPPorts = [ 2049 ];
      # services.rpcbind.enable = true;
    })
  ];
}
