{ inputs, cell, ... }:

{ self, config, lib, pkgs, ... }:
with lib;
let
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

  # echo next-server: ''${next-server}
  # echo www-server: ''${www-server}
  # echo ''${hostname}.''${net0/domain}
  # echo IP : ''${net0/ip} / ''${net0/netmask}
  # isset ''${net0/gateway} && echo GW : ''${net0/gateway} || echo GW : nil
  # echo DNS: ''${net0/dns}

  # www-server [72]
  #
  # show 175.188 = san-filename etc...
  #  http://192.168.0.1/boot.php?mac=${net0/mac}&asset=${asset:uristring}
  #  iseq ${platform} efi && goto is_efi || goto not_efi
  ipxeDefault = { menu_items ? "", menu_blocks ? "", dir ? "boot" }: pkgs.writeTextDir "${dir}/default.ipxe" ''
    #!ipxe
    chain --replace --autofree http://boot-http.njk.local/mutable/http_boot/ipxe/default.ipxe
  '';

  ipxeDefaultOld = { menu_items ? "", menu_blocks ? "", dir ? "boot" }: pkgs.writeTextDir "${dir}/default.ipxe" ''
    #!ipxe

    isset ''${72:ipv4} && set www-server ''${72:ipv4} || set www-server boot-http

    set proto http:/
    set mutable-url ''${proto}/''${www-server}/mutable
    set base-url ''${proto}/''${www-server}/boot

    set host-known  ''${base-url}/''${hostname}/netboot.ipxe
    set host-unknown ''${base-url}/maintenance/netboot.ipxe

    isset ''${www-server} && console --picture ''${mutable-url}/http_boot/logo/ufp_s31_logo.png --keep || console --x 1280 --y 720

    :start
    menu ''${hostname} [''${platform}] - ''${net0/ip}/''${net0/netmask} GW: ''${net0/gateway} DNS: ''${net0/dns}
    item --key b bootstrap bootstrap
    item --key n nfsroot bootstrap-nfsroot
    item --key f freedos FreeDOS
    item --key m mutable mutable configs
    item --key s shell shell
    # ${menu_items}
    choose --default after-timeout --timeout 10000 target && goto ''${target}

    :after-timeout
    isset ''${hostname} && chain ''${host-known} || chain ''${host-unknown}

    # ${menu_blocks}

    :bootstrap
    chain ''${base-url}/bootstrap/netboot.ipxe || goto start

    :freedos
    iseq ''${platform} efi && goto start || sanboot --keep http://''${mutable-url}/freedos/FD13LIVE.iso

    :mutable
    chain --autofree --replace ''${mutable-url}/http_boot/mutable.ipxe

    :shell
    echo Type 'exit' to get the back to the menu
    shell
    set menu-timeout 0
    set submenu-timeout 0
    goto start
  '';

  # set manufacturer njk
  # set product pxe-boot
  # set asset ipxe-script

  ipxe = (pkgs.ipxe-git.override {
    embedScript = pkgs.writeText "embedded_client-class" ''
      #!ipxe
      set vendor-class ${config.deploy.params.lan.server.kea-dhcp.ipxeClassMatch}
      autoboot
    '';
  });

  # echo LOADED ''${user-class}
  # echo ''${net0/ip}/''${net0/netmask} via ''${net0/gateway} DNS: ''${net0/dns} - ''${hostname}
  # sleep 30
  # shell

  bootables = pkgs.linkFarm "bootable_images" (map
    (host: {
      name = "boot/${host}";
      path = getAttrFromPath [ host "config" "system" "build" "ipxeBootDir" ] self.nixosConfigurations;
    })
    (attrNames (filterAttrs (_: v: with v.config.deploy; (hasAttrByPath [ "lan" "ipxe" ] params) && params.lan.ipxe == true) self.nixosConfigurations)));

in
{ services.netboot.root = [ (ipxeDefault { }) ipxe bootables ]; }
