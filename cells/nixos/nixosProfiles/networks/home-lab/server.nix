{ inputs, cell, ... }:

{ profiles, lib, pkgs, ... }:
with lib;

let
  network = "10.11.1.0/24";
  domain = "njk.local";
  pref = concatStringsSep "." (take 3 (splitString "." network));
  mask = last (splitString "/" network);
  firstAddr = op: head (splitString "/" (head op.addresses).addressConfig.Address);
  addrSuffix = op: last (splitString "." (firstAddr op));
  timezone = "CET";
  reservationsOptions = { ... }: { optons = with types; { }; };

in
{
  imports = with profiles.networking;[
    #### Networking services
    lan.gateway
    lan.ipxe
    lan.zerotier-controller
    lan.powerdns-recursor
    lan.powerdns-native
    lan.powerdns-admin
    lan.postgresql-dns-dhcp
    ### Requires lots of host memory!
    # lan.mongodb-server
    # lan.elasticsearch-server
    # lan.graylog-server
    lan.ntp-server
    lan.syslog-server
    lan.tftp-boot-server
    lan.http-boot-server
    lan.dhcp-boot-server
    lan.git-hosting
  ];

  # TODO: a proper module of this mess!
  options.services.netboot = with types; {
    root = mkOption {
      type = nullOr (listOf package);
      default = null;
      apply = paths: pkgs.symlinkJoin { inherit paths; name = "netboot-root-${domain}"; };
    };

    reservations = mkOption { type = nullOr (attrsOf (submodule [ reservationsOptions ])); };
  };

  config =
    {

      deploy.params.lan.server = rec {
        inherit network domain;
        namespace = "lan-" + domain;
        macvlans = [ "lan" ];
        networkConfig.Gateway = "${pref}.254";

        gateway = {
          addresses = [{ addressConfig.Address = "${pref}.111/${mask}"; }];
        };

        recursor = {
          addresses = [{ addressConfig.Address = "${pref}.4/${mask}"; }];
          forwardZones = {
            ${domain} = "${firstAddr dns-native}:53";
            "10.in-addr.arpa" = "${firstAddr dns-native}:53";
          };
        };

        git-hosting = {
          lfsLoc = "/persist/git/lfs";
          addresses = [{ addressConfig.Address = "${pref}.10/${mask}"; }];
        };

        dns-native = {
          addresses = [{ addressConfig.Address = "${pref}.2/${mask}"; }];
        };

        kea-dhcp = {
          common-option-data = [
            { name = "domain-name-servers"; data = firstAddr recursor; }
            { name = "domain-search"; data = domain; }
            { name = "time-servers"; data = firstAddr ntp-server; }
            { name = "ntp-servers"; data = firstAddr ntp-server; }
            { name = "log-servers"; data = firstAddr syslog-server; }
            # finger-server
            # sun ray client { name = "x-display-manager"; data = ""; }
          ];

          dhcp-ddns = {
            forward-ddns.ddns-domains = [

              {
                name = "install." + domain + ".";
                dns-servers = [{ ip-address = firstAddr dns-native; }];
              }

              {
                name = "admin." + domain + ".";
                dns-servers = [{ ip-address = firstAddr dns-native; }];
              }

              {
                name = "k3s." + domain + ".";
                dns-servers = [{ ip-address = firstAddr dns-native; }];
              }

              {
                name = domain + ".";
                dns-servers = [{ ip-address = firstAddr dns-native; }];
              }

            ];

            reverse-ddns.ddns-domains = [{
              name = "10.in-addr.arpa" + ".";
              # key-name = "";
              dns-servers = [{ ip-address = firstAddr dns-native; }];
            }];
          };

          # kyocera mac 00:17:c8:bc:ab:fb
          ipxeClassMatch = "COMPAT";
          addresses = [{ addressConfig.Address = "${pref}.250/${mask}"; }];
          subnet4 = [
            {
              # inherit reservations;
              # NOTE: require-client-classes and client-classes = [{only-if-required = true;}];
              reservations = [
                {
                  hostname = "kyocera-printer";
                  hw-address = "00:17:c8:bc:ab:fb";
                  ip-address = "${pref}.195";
                  # option-data = [{ name = "netbios-name-servers"; data = ""; }];
                }

                {
                  hostname = "bootstrap-nfsroot";
                  hw-address = "5a:a7:c1:59:1a:1f";
                  ip-address = "${pref}.111";
                  option-data = [
                    { name = "boot-file-name"; data = "ipxe.efi"; }
                    # { name = "root-path"; data = "frogstar.njk.local:/nfsroot/bootstrap,vers=4.2,proto=tcp"; }
                  ];
                }

              ];

              subnet = network;
              server-hostname = firstAddr tftp-server;
              pools = [{ pool = "10.11.1.100 - 10.11.1.249"; }];
              interface = "lan";
              # [ddns-generated-prefix]-[address-text].[ddns-qualifying-suffix]
              ddns-generated-prefix = "host";
              ddns-qualifying-suffix = domain;
              ### NOTE: https://kea.readthedocs.io/en/kea-2.0.1/arm/dhcp4-srv.html#dhcp4-std-options-list
              ### NOTE: https://kea.readthedocs.io/en/kea-2.0.1/arm/classify.html#using-expressions-in-classification
              #reservations =
              option-data = kea-dhcp.common-option-data ++ [
                { name = "routers"; data = networkConfig.Gateway; }
                { name = "domain-name"; data = domain; }
              ];
            }
          ];

          vpn-bridges = {
            zerotierone.install =
              let
                duke = "10.100.0";
              in
              {
                subnet4 = [{
                  subnet = "${duke}.0/24";
                  pools = [{ pool = "${duke}.101 - ${duke}.150"; }];
                  ddns-generated-prefix = "host";
                  ddns-qualifying-suffix = "install." + domain;
                  option-data = kea-dhcp.common-option-data ++ [
                    { name = "routers"; data = duke + "." + (addrSuffix gateway); }
                    { name = "domain-name"; data = "install.njk.li"; }
                  ];

                  # reservations = [
                  #   {
                  #     hostname = "gateway";
                  #     # hw-address = "5c:85:7e:48:56:cb";
                  #     ip-address = "${duke}.1";
                  #     # option-data = [{ name = "boot-file-name"; data = "snponly.efi"; }];
                  #   }
                  # ];
                }];
                bridgeIP = duke + "." + (addrSuffix kea-dhcp);
                # IPMasquerade = "ipv4";
                joinNetworks = [{ "d3b09dd7f53d1214" = "kea-inst"; }];
              };

            zerotierone.admin =
              let
                duke = "10.22.0";
              in
              {
                subnet4 = [{
                  subnet = "${duke}.0/24";
                  pools = [{ pool = "${duke}.101 - ${duke}.150"; }];
                  ddns-generated-prefix = "machine";
                  ddns-qualifying-suffix = "admin." + domain;
                  option-data = kea-dhcp.common-option-data ++ [
                    { name = "routers"; data = duke + "." + (addrSuffix gateway); }
                    { name = "domain-name"; data = "admin.njk.li"; }
                  ];
                  reservations = [
                    {
                      # "identifier-type": <one of 'hw-address', 'duid', 'circuit-id', 'client-id' and 'flex-id'>
                      hostname = "gateway";
                      client-id = "ff:b6:5b:87:1e:00:02:00:00:ab:11:33:bb:51:02:a4:f7:5a:59";
                      ip-address = "${duke}.1";
                      # option-data = [{ name = "boot-file-name"; data = "snponly.efi"; }];
                    }
                  ];
                }];
                bridgeIP = duke + "." + (addrSuffix kea-dhcp);
                # IPMasquerade = "ipv4";
                joinNetworks = [{ "d3b09dd7f51f90df" = "kea-admin"; }];
              };

            zerotierone.k3s =
              let
                duke = "10.33.0";
              in
              {
                subnet4 = [{
                  subnet = "${duke}.0/24";
                  pools = [{ pool = "${duke}.101 - ${duke}.150"; }];
                  ddns-generated-prefix = "node";
                  ddns-qualifying-suffix = "k3s." + domain;
                  option-data = kea-dhcp.common-option-data ++ [
                    { name = "routers"; data = duke + "." + (addrSuffix gateway); }
                    { name = "domain-name"; data = "admin.njk.li"; }
                  ];
                }];
                bridgeIP = duke + "." + (addrSuffix kea-dhcp);
                # IPMasquerade = "ipv4";
                joinNetworks = [{ "d3b09dd7f58387ff" = "k3s-ipam"; }];
              };

          };
        };

        tftp-server = {
          addresses = [{ addressConfig.Address = "${pref}.11/${mask}"; }];
        };

        http-server = {
          mutableDirs = [ "/persist/opt/http_boot" "/nfsroot/iso" ];
          addresses = [{ addressConfig.Address = "${pref}.12/${mask}"; }];
        };

        powerdns-admin = {
          addresses = [{ addressConfig.Address = "${pref}.5/${mask}"; }];
        };

        postgresql = {
          addresses = [{ addressConfig.Address = "${pref}.20/${mask}"; }];
        };

        mongodb-server = {
          addresses = [{ addressConfig.Address = "${pref}.21/${mask}"; }];
        };

        elasticsearch-server = {
          addresses = [{ addressConfig.Address = "${pref}.22/${mask}"; }];
        };

        graylog-server = {
          addresses = [{ addressConfig.Address = "${pref}.25/${mask}"; }];
        };

        ntp-server = {
          addresses = [{ addressConfig.Address = "${pref}.30/${mask}"; }];
        };

        syslog-server = {
          addresses = [{ addressConfig.Address = "${pref}.31/${mask}"; }];
        };

        iscsi-server = {
          # TODO:
          addresses = [{ addressConfig.Address = "${pref}.29/${mask}"; }];
        };

        nixery-server = {
          # TODO:
          addresses = [{ addressConfig.Address = "${pref}.33/${mask}"; }];
        };

        zerotier-controller = {
          addresses = [{ addressConfig.Address = "${pref}.32/${mask}"; }];
        };

      };

    };
}
