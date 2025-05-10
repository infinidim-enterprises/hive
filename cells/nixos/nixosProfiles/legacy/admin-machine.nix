{ inputs, cell, ... }:

{ self, config, pkgs, lib, ... }:
{
  # eadrax mac "16:07:77:00:aa:ff"
  # systemd.network.networks.lan.linkConfig.MACAddress = lib.mkForce "16:07:77:00:aa:ff";

  # systemd.services.postgresql.preStart = with config.services.postgresql; lib.mkAfter ''
  #   [[ -e  "${dataDir}/.first_startup" ]] && touch "${dataDir}/.first_startup_user"
  # '';

  # systemd.services.postgresql.postStart = with config.services.postgresql; lib.mkAfter ''
  #   if test -e "${dataDir}/.first_startup_user"; then
  #     psql --port=${builtins.toString port} -f "${pkgs.powerdns}/share/doc/pdns/schema.pgsql.sql" -d powerdns
  #     rm -f "${dataDir}/.first_startup_user"
  #   fi
  # '';

  services.postgresql = {
    # NOTE: extraPlugins = [ pkgs.postgresql.pkgs.pg_ed25519 ];
    enable = false;
    # initialScript = ''
    #   SET search_path = powerdns;
    # ''
    # + (fileContents "${pkgs.powerdns}/share/doc/pdns/schema.pgsql.sql")
    # + ''
    #         '';
    ensureDatabases = [ "powerdnsadmin" "powerdns" ];
    ensureUsers = [
      {
        name = "powerdnsadmin";
        ensurePermissions = { "DATABASE powerdnsadmin" = "ALL PRIVILEGES"; };
      }

      {
        name = "powerdns";
        ensurePermissions = { "DATABASE powerdns" = "ALL PRIVILEGES"; };
      }

    ];
  };

  networking.firewall.allowedTCPPorts = [ 8081 4443 ];
  networking.firewall.allowedUDPPorts = [ 9994 ];
  programs.traceroute.enable = true;

  # eadrax pk "3d806c5763:0:f4e755de5418e448b26cf181d49514d0a247a15c979c300f731b4e598b987c324f8919df989fcd7bc496f22b14d1b42cfc370a735d533771ab5e746635620425:1682fc98132ef5b4d4cce34eded477fc9e01497f9fa0f57999be675b1f61fc8e5d2e8339c48de0f19555d187e499ef0da35d28f968e8b07fff4e70059d7ca487"

  services.zerotierone.enable = true;
  services.zerotierone.localConf.settings.interfacePrefixBlacklist = [ "admin-int" ];
  services.zerotierone.localConf.physical."10.22.0.0/24".blacklist = true;

  services.zerotierone.service_script_timeout = 5;
  # services.zerotierone.joinNetworks = [
  #   #{ "be7a7d8eeae1f0c6" = "legacy-admin"; } # admin
  #   { "d3b09dd7f53d1214" = "install"; }
  #   { "d3b09dd7f51f90df" = "admin-dhcp"; }
  #   { "d3b09dd7f50e3236" = "admin-znsd"; }
  # ];
  networking.firewall.trustedInterfaces = [ "admin-dhcp" "admin-znsd" ];
  # Eadrax

  # services.zerotierone.privateKey = "";

  age.secrets."legacy-zerotier" = {
    file = "${self}/secrets/hosts/eadrax/zerotier-legacy.pk.age";
    mode = "0600";
    path = "/persist/${config.services.zerotierone.homeDir}/identity.secret";
  };

  # services.zerotierone.localConf.physical."10.11.1.0/24" = { blacklist = false; trustedPathId = 10110124; };
  # services.zerotierone.localConf.virtual = {
  #   "0ab840083c" = { try = [ "10.11.1.11/9993" ]; };
  #   "355e4f5ce9" = { try = [ "10.11.1.41/9993" ]; };
  #   "55880ea9db" = { try = [ "10.11.1.50/9993" ]; };
  #   "59a51d4058" = { try = [ "10.11.1.251/9993" ]; };
  #   "6763e3df3b" = { try = [ "10.11.1.177/9993" ]; };
  #   "6870c2cb7a" = { try = [ "10.11.1.254/9993" ]; };
  #   "71e3c85f22" = { try = [ "10.11.1.55/9993" ]; };
  #   "7a5d339c23" = { try = [ "10.11.1.115/9993" ]; };
  #   "7b755d8bc8" = { try = [ "10.11.1.42/9993" ]; };
  #   "9efefdff87" = { try = [ "10.11.1.43/9993" ]; };
  #   a69611a55d = { try = [ "10.11.1.121/9993" ]; };
  #   a7944fed59 = { try = [ "10.11.1.77/9993" ]; };
  #   be7a7d8eea = { try = [ "10.11.1.111/9993" ]; };
  #   c54f1a724e = { try = [ "10.11.1.60/9993" ]; };
  #   e711b4418a = { try = [ "10.11.1.45/9993" ]; };
  #   eedc965ab1 = { try = [ "10.11.1.185/9993" ]; };
  #   f0361d8c15 = { try = [ "10.11.1.222/9993" ]; };
  #   f4eecba373 = { try = [ "10.11.1.40/9993" ]; };
  #   f81ed96fba = { try = [ "10.11.1.80/9993" ]; };
  # };

  # networking.hosts = {
  #   "10.11.1.254" = [ "frogstar.0.njk.li" ];
  #   "10.22.0.254" = [ "git.0a.njk.li" "frogstar.0a.njk.li" ];
  # };

  networking.hosts."10.11.1.254" = [ "frogstar.njk.local" ];
  networking.hosts."10.11.1.195" = [ "kyocera-printer.njk.local" "kyocera-printer" ];

  services.nfsv4.client.enable = true;
  services.nfsv4.client.mounts = [
    "frogstar.njk.local:/backup"
    "frogstar.njk.local:/downloads"
    "frogstar.njk.local:/http_boot"
  ];
}
