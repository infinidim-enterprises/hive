{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.networks;

  hostOptionData = with types; { ... }: {
    options = { name = mkOption { default = null; type = nullOr str; }; data = mkOption { default = null; type = nullOr str; }; };
  };

  commonHostOptions = with types; { ... }: {
    options = {
      hostname = mkOption { default = null; type = nullOr str; };
      hw-address = mkOption { default = null; type = nullOr str; };
      ip-address = mkOption { default = null; type = nullOr str; };
      option-data = mkOption { default = null; type = nullOr (listOf (submodule [ hostOptionData ])); };
    };
  };

  commonNetworkOptions = with types; { name, ... }: {
    options = {
      # client =
      domain = mkOption { type = str; default = name; description = "domain name, defaults to network designation"; };
      macvlan = mkOption { type = nullOr str; default = "lan"; description = "macvlan interface to use for this network"; };
      namespace = mkOption { type = str; description = "Prefix for systemd container name"; default = "${cfg.${name}.macvlan}-${name}-"; };
      sql = mkOption { enable = mkEnableOption "postgresql for dns/dhcp"; };
      hosts = mkOption { type = listOf (submodule [ commonHostOptions ]); };
    };
  };

in
{
  #### Networking services
  # lan.gateway
  # lan.ipxe
  # lan.zerotier-controller
  # lan.powerdns-recursor
  # lan.powerdns-native
  # lan.powerdns-admin
  # lan.postgresql-dns-dhcp
  ### Requires lots of host memory!
  # lan.mongodb-server
  # lan.elasticsearch-server
  # lan.graylog-server
  ###
  # lan.ntp-server
  # lan.syslog-server
  # lan.tftp-boot-server
  # lan.http-boot-server
  # lan.dhcp-boot-server
  # lan.git-hosting

  imports = [ ];
  options.networks = with types; mkOption { type = attrsOf (submodule [ commonNetworkOptions ]); };
  config = mkMerge [
    # { assertions = [{ assertion = isNetworkd; message = "Requires systemd.network.enable"; }]; }
    { }
  ];
}
