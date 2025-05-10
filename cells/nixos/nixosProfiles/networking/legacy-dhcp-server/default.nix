{ inputs, cell, ... }:

{ config, self, lib, pkgs, ... }:
with lib;
let

  freedos = with pkgs; stdenv.mkDerivation {
    inherit (sources.freedos) pname version src;
    buildInputs = [ unzip ];
    phases = [ "buildPhase" ];
    buildPhase = ''
      loc=$out/boot/freedos
      mkdir -p $loc
      unzip $src
      mv *.img $loc
      mv *.iso $loc
    '';
  };

  rescuezilla = pkgs.linkFarm "rescuezilla" [
    {
      name = "boot/rescuezilla/rescuezilla.iso";
      path = pkgs.sources.rescuezilla.src;
    }
  ];

  ipxeDefault = { menu_items ? "", menu_blocks ? "", dir ? "boot" }: pkgs.writeTextDir "${dir}/default.ipxe" ''
    #!ipxe

    set proto http:/
    set base-url ''${proto}/''${next-server}/boot
    set host-known  ''${base-url}/''${hostname}/netboot.ipxe
    set host-unknown ''${base-url}/maintenance/netboot.ipxe

    echo next-server: ''${next-server}
    echo ''${hostname}.''${net0/domain}
    echo IP : ''${net0/ip} / ''${net0/netmask}
    isset ''${net0/gateway} && echo GW : ''${net0/gateway} || echo GW : nil
    echo DNS: ''${net0/dns}

    # :version_check
    # set latest_version 1.21.1+ (g3662)
    # echo ''${cls}
    # iseq ''${version} ''${latest_version} && goto version_up2date ||
    # echo
    # echo Updated version of iPXE is available:
    # echo
    # echo Running version.....''${version}
    # echo Updated version.....''${latest_version}
    # echo
    # echo Attempting to chain to latest version...
    # chain --autofree ''${proto}/''${next-server}/ipxe.lkrn ||

    # :version_up2date

    :start
    menu ''${net0/ip}/''${net0/netmask} GW: ''${net0/gateway} DNS: ''${net0/dns} - ''${hostname} -
    item --key b bootstrap bootstrap
    item --key f freedos FreeDOS
    item --key r rescuezilla rescuezilla
    item --key s shell shell
    item rescuezilla1 rescuezilla1
    # ${menu_items}
    choose --default after-timeout --timeout 5000 target && goto ''${target}

    :after-timeout
    isset ''${hostname} && chain ''${host-known} || chain ''${host-unknown}

    # ${menu_blocks}

    :bootstrap
    chain ''${base-url}/bootstrap/netboot.ipxe

    :freedos
    sanboot --keep http://''${next-server}/boot/freedos/FD13LIVE.iso || goto start

    :rescuezilla1
    sanboot http://''${next-server}/boot/rescuezilla/rescuezilla.iso || goto start

    :rescuezilla
    sanboot --no-describe --keep http://''${next-server}/boot/rescuezilla/rescuezilla.iso || goto start

    :shell
    echo Type 'exit' to get the back to the menu
    shell
    set menu-timeout 0
    set submenu-timeout 0
    goto start
  '';

  userClassString = "COMPAT";
  # convertToChars = str: concatMapStringsSep ", " (c: "'${c}'") (stringToCharacters str);

  custom_ipxe = (pkgs.ipxe-git.override {
    embedScript = pkgs.writeText "embedded_client-class" ''
      #!ipxe
      set user-class ${userClassString}
      autoboot
    '';
  });

  populateBootDir = pkgs.linkFarm "bootable_images" (map
    (host: {
      name = "boot/${host}";
      path = getAttrFromPath [ host "config" "system" "build" "ipxeBootDir" ] self.nixosConfigurations;
    })
    (attrNames (filterAttrs (_: v: with v.config.deploy; (hasAttrByPath [ "lan" "ipxe" ] params) && params.lan.ipxe == true) self.nixosConfigurations)));

  bootDir = pkgs.symlinkJoin {
    name = "netboot_root";
    paths = [
      custom_ipxe
      freedos
      rescuezilla
      # populateBootDir
      (ipxeDefault { })
    ];

    # postBuild = ''
    #   mkdir -p $out
    #   ln -s -f ${pkgs.ipxe}/ipxe.efi $out/ipxe_nixpkgs.efi
    # '';
  };

  defaultInterface = "lan";
  tftpIp = "10.11.1.254";
  getCfg = host: self.nixosConfigurations.${host}.config;
  getIP = ip: "10.11.1." + (last (splitString "." (head (splitString "/" ip))));
  lanHosts = filter
    (host:
      let cfg = getCfg host; in
      (cfg.deploy.params.lan.ipv4 != null) &&
      (config.networking.hostName != cfg.networking.hostName))
    (attrNames self.nixosConfigurations);

  reservations = map
    (host:
      let cfg = (getCfg host).deploy.params.lan; in
      ({ ip-address = getIP cfg.ipv4; hostname = (getCfg host).networking.hostName; } // optionalAttrs (cfg.mac != null) { hw-address = cfg.mac; }))
    lanHosts;
in
{
  imports = [ ./_zerotierone-bridges.nix ];
  config = mkMerge [
    {
      # NOTE: networking.firewall.interfaces.${defaultInterface}.allowedUDPPorts = [ 69 ];
      networking.firewall.allowedUDPPorts = [ 69 ];
      services.atftpd.enable = true;
      services.atftpd.root = bootDir;
      services.atftpd.extraOptions = [
        "--bind-address 0.0.0.0"
        # "--bind-address ${tftpIp}"
        # "--verbose=7"
      ];
    }

    {
      networking.firewall.allowedTCPPorts = [ 80 ];
      services.httpd.enable = true;
      services.httpd.virtualHosts.localhost = {
        documentRoot = bootDir;
        adminAddr = "httpd@${config.networking.hostName}.${config.networking.domain}";
        listen = [{ ip = "*"; port = 80; }];
      };
    }

    {
      networking.firewall.allowedUDPPorts = [ 67 ];
      services.kea.dhcp4 = {
        enable = true;

        settings = {
          # 72h * 60 * 60
          valid-lifetime = 259200;
          renew-timer = 259200;
          # rebind-timer = 1800;

          multi-threading = {
            enable-multi-threading = true;
            thread-pool-size = 4;
            packet-queue-size = 64;
          };

          ### NOTE: https://kea.readthedocs.io/en/kea-2.0.1/arm/lease-expiration.html?highlight=valid-lifetime
          # expired-leases-processing = {
          #   reclaim-timer-wait-time = 5;
          #   max-reclaim-leases = 0;
          #   max-reclaim-time = 0;
          # };

          loggers = let pattern = "%d{%j %H:%M:%S.%q} %c %m\n"; in
            [
              {
                name = "kea-dhcp4";
                output_options = [{ output = "stdout"; inherit pattern; }];
                severity = "INFO";
              }

              # {
              #   name = "kea-dhcp4.eval";
              #   output_options = [{ output = "/tmp/kea-debug.eval"; inherit pattern; }];
              #   severity = "DEBUG";
              #   debuglevel = 99;
              # }
            ];

          lease-database = {
            persist = true;
            type = "memfile";
            name = "/var/lib/kea/dhcp4.leases";
          };

          interfaces-config = {
            dhcp-socket-type = "raw";
            interfaces = [ defaultInterface ];
          };

          option-def = [
            # responses
            { code = 1; name = "priority"; space = "ipxe"; type = "int8"; }
            { code = 8; name = "keep-san"; space = "ipxe"; type = "uint8"; }
            { code = 9; name = "skip-san-boot"; space = "ipxe"; type = "uint8"; }
            { code = 85; name = "syslogs"; space = "ipxe"; type = "string"; }
            { code = 91; name = "cert"; space = "ipxe"; type = "string"; }
            { code = 92; name = "privkey"; space = "ipxe"; type = "string"; }
            { code = 93; name = "crosscert"; space = "ipxe"; type = "string"; }
            { code = 176; name = "no-pxedhcp"; space = "ipxe"; type = "uint8"; }
            { code = 177; name = "bus-id"; space = "ipxe"; type = "string"; }
            { code = 188; name = "san-filename"; space = "ipxe"; type = "string"; }
            { code = 189; name = "bios-drive"; space = "ipxe"; type = "uint8"; }
            { code = 190; name = "username"; space = "ipxe"; type = "string"; }
            { code = 191; name = "password"; space = "ipxe"; type = "string"; }
            { code = 192; name = "reverse-username"; space = "ipxe"; type = "string"; }
            { code = 193; name = "reverse-password"; space = "ipxe"; type = "string"; }
            { code = 235; name = "version"; space = "ipxe"; type = "string"; }
            { code = 203; name = "iscsi-initiator-iqn"; space = "dhcp4"; type = "string"; }
            # features
            { code = 16; name = "pxeext"; space = "ipxe"; type = "uint8"; }
            { code = 17; name = "iscsi"; space = "ipxe"; type = "uint8"; }
            { code = 18; name = "aoe"; space = "ipxe"; type = "uint8"; }
            { code = 19; name = "http"; space = "ipxe"; type = "uint8"; }
            { code = 20; name = "https"; space = "ipxe"; type = "uint8"; }
            { code = 21; name = "tftp"; space = "ipxe"; type = "uint8"; }
            { code = 22; name = "ftp"; space = "ipxe"; type = "uint8"; }
            { code = 23; name = "dns"; space = "ipxe"; type = "uint8"; }
            { code = 24; name = "bzimage"; space = "ipxe"; type = "uint8"; }
            { code = 25; name = "multiboot"; space = "ipxe"; type = "uint8"; }
            { code = 26; name = "slam"; space = "ipxe"; type = "uint8"; }
            { code = 27; name = "srp"; space = "ipxe"; type = "uint8"; }
            { code = 32; name = "nbi"; space = "ipxe"; type = "uint8"; }
            { code = 33; name = "pxe"; space = "ipxe"; type = "uint8"; }
            { code = 34; name = "elf"; space = "ipxe"; type = "uint8"; }
            { code = 35; name = "comboot"; space = "ipxe"; type = "uint8"; }
            { code = 36; name = "efi"; space = "ipxe"; type = "uint8"; }
            { code = 37; name = "fcoe"; space = "ipxe"; type = "uint8"; }
            { code = 38; name = "vlan"; space = "ipxe"; type = "uint8"; }
            { code = 39; name = "menu"; space = "ipxe"; type = "uint8"; }
            { code = 40; name = "sdi"; space = "ipxe"; type = "uint8"; }
            { code = 41; name = "nfs"; space = "ipxe"; type = "uint8"; }
            { name = "ipxe-encap-opts"; code = 175; encapsulate = "ipxe"; space = "dhcp4"; type = "empty"; }
            # { name = "custom-test"; code = 215; space = "dhcp4"; type = "string"; array = false; }
          ];

          client-classes = [
            # NOTE: order matters!
            {
              # TODO: send signed/trusted img here
              name = "iPXE_HTTPS";
              test = "option[175].option[20].exists";
            }

            {
              # upgrade session here
              name = "iPXE_COMPAT";
              test = "substring(option[77].hex,0,${toString (stringLength userClassString)}) == '${userClassString}'";
              next-server = tftpIp;
              boot-file-name = "http://${tftpIp}/boot/default.ipxe";
            }

            {
              name = "BIOS";
              test = "option[93].hex == 0x0000";
            }

            {
              name = "iPXE";
              test = "substring(option[77].hex,0,4) == 'iPXE'";
            }

            {
              name = "UEFI_32";
              test = "not member('iPXE') and (option[93].hex == 0x0002 or option[93].hex == 0x0006)";
            }

            {
              name = "UEFI_64";
              test = "not member('iPXE') and (option[93].hex == 0x0007 or option[93].hex == 0x0008 or option[93].hex == 0x0009)";
            }

            {
              name = "UEFI_HTTP";
              test = "not (member('iPXE') or member('iPXE_COMPAT')) and (member('UEFI_32') or member('UEFI_64')) and substring(option[60].hex,0,10) == 'HTTPClient'";
              boot-file-name = "http://${tftpIp}/ipxe.efi";
              option-data = [{ name = "vendor-class-identifier"; data = "HTTPClient"; }];
            }

            {
              name = "UEFI_PXE";
              test = "not (member('iPXE') or member('iPXE_COMPAT')) and (member('UEFI_32') or member('UEFI_64')) and substring(option[60].hex,0,9) == 'PXEClient'";
              boot-file-name = "ipxe.efi";
              option-data = [{ name = "tftp-server-name"; data = tftpIp; }];
            }

            {
              # NOTE: Bios / non-efi
              # NOTE: Try with real hardware clients, the boot-file-name might need to be without protocol spec!
              name = "Legacy";
              test = "member('BIOS') and not (member('iPXE') or member('iPXE_COMPAT'))";
              boot-file-name = "undionly.kpxe";
              option-data = [{ name = "tftp-server-name"; data = tftpIp; }];
            }

            {
              name = "iPXE_UEFI_INCOMPAT";
              # 17 18 19 20 21 23 27 36 39
              test = "(member('UEFI_32') or member('UEFI_64')) and member('iPXE')";
              boot-file-name = "http://${tftpIp}/ipxe.efi";
            }

            {
              name = "iPXE_BIOS_INCOMPAT";
              # 16 17 18 19 21 23 24 25 33 34 39
              test = "member('BIOS') and member('iPXE')";
              boot-file-name = "http://${tftpIp}/ipxe.lkrn";
            }

            {
              name = "IPXE_CLIENTS";
              # 16 17 18 19 20 21 23 24 25 27 33 34 39
              test = "member('iPXE') or member('iPXE_COMPAT')";
              option-data = [
                { space = "ipxe"; always-send = true; name = "no-pxedhcp"; data = "1"; }
                # { space = "ipxe"; always-send = true; name = "keep-san"; data = "1"; }
                # { space = "ipxe"; always-send = true; name = "syslogs"; data = "syslogs.0.njk.li"; }
                # { space = "ipxe"; always-send = true; name = "cert"; data = "Arriving here like that!"; }
                # { space = "ipxe"; always-send = true; name = "version"; data = "1.2.1"; }
                # { space = "ipxe"; always-send = true; name = "username"; data = "SOMEUSER"; }
                { name = "ipxe-encap-opts"; }
                # { name = "custom-test"; data = "Custom_string"; always-send = true; }
              ];
            }
          ];

          subnet4 = [
            {
              inherit reservations;
              subnet = "10.11.1.0/24";
              server-hostname = tftpIp;
              pools = [{ pool = "10.11.1.10 - 10.11.1.250"; }];
              interface = defaultInterface;
              ### NOTE: https://kea.readthedocs.io/en/kea-2.0.1/arm/dhcp4-srv.html#dhcp4-std-options-list
              ### NOTE: https://kea.readthedocs.io/en/kea-2.0.1/arm/classify.html#using-expressions-in-classification

              option-data = [
                { name = "domain-name-servers"; data = "8.8.8.8"; }
                { name = "domain-name"; data = "0.njk.li"; }
                { name = "routers"; data = tftpIp; }
              ];

            }
          ];

        };

      };
    }
  ];
}

/*
  TODO: http://spritelink.github.io/NIPAP/docs/install-unix.html
  dhcp-host=16:07:77:03:aa:ff,set:wifigw,10.11.1.222,argabuthon
  dhcp-host=id:av-container,set:vpn,10.11.1.115,av-container
  dhcp-host=16:07:77:01:aa:ff,set:wifigw,10.11.1.60,bartrax
  dhcp-host=16:07:77:00:aa:ff,set:wifigw,10.11.1.220,eadrax
  dhcp-host=16:07:77:05:aa:ff,10.11.1.40,folfanga
  dhcp-host=16:07:77:06:aa:ff,10.11.1.41,folfanga-1
  dhcp-host=16:07:77:07:aa:ff,10.11.1.42,folfanga-2
  dhcp-host=16:07:77:0a:aa:ff,10.11.1.43,folfanga-3
  dhcp-host=16:07:77:ff:a1:ff,id:frogstar,10.11.1.254,frogstar
  dhcp-host=id:gitea-container,10.11.1.121,gitea-container
  dhcp-host=16:07:77:04:aa:ff,set:wifigw,10.11.1.80,ipc
  dhcp-host=id:ipxe-container,set:vpn,10.11.1.250,ipxe-container
  dhcp-host=28:d2:44:84:7e:82,10.11.1.185,jules
  dhcp-host=16:07:77:00:11:1f,set:wifigw,10.11.1.77,maintenance
  dhcp-host=16:07:77:0b:aa:ff,id:marvin,10.11.1.55,marvin
  dhcp-host=16:07:77:00:00:ff,id:networkd-tests,10.11.1.177,networkd-tests
  dhcp-host=16:07:77:02:aa:ff,set:wifigw,10.11.1.251,traal
  dhcp-host=16:07:77:a2:aa:ff,set:vpn,10.11.1.120,vpn-proxy-container
  dhcp-host=id:zeronet-host,10.11.1.112,zeronet-host
  dhcp-host=16:07:77:a1:aa:ff,10.11.1.111,zerotier-controller
  dhcp-host=id:zt-test-container,10.11.1.114,zt-test-container
*/
