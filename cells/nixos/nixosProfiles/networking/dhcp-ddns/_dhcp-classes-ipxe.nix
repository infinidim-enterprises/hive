{ cfg, lib, httpIp, tftpIp, lan }:
with lib;
with builtins;
[
  # NOTE: order matters!
  # {
  #   # TODO: send signed/trusted img here
  #   name = "iPXE_HTTPS";
  #   test = "option[175].option[20].exists";
  # }

  {
    # upgrade session here
    name = "iPXE_COMPAT";
    test = "option[vendor-class-identifier].text == '${cfg.ipxeClassMatch}'";
    # test = "option[175].option[20].exists and substring(option[77].hex,0,${toString (stringLength cfg.ipxeClassMatch)}) == '${cfg.ipxeClassMatch}'";
    # Next Server is - some say it should be (siaddr), others that it should be the tftpIp
    boot-file-name = "http://${httpIp}/boot/default.ipxe";
    option-data = [
      { name = "www-server"; data = httpIp; always-send = true; }
    ];
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
    boot-file-name = "http://${httpIp}/ipxe.efi";
    option-data = [{ name = "vendor-class-identifier"; data = "HTTPClient"; }];
  }

  {
    name = "UEFI_PXE";
    test = "not (member('iPXE') or member('iPXE_COMPAT')) and (member('UEFI_32') or member('UEFI_64')) and substring(option[60].hex,0,9) == 'PXEClient'";
    # NOTE: RTL 10EC:8168 rev15 - doesn't work otherwise!
    boot-file-name = "snponly.efi";
    # boot-file-name = "ipxe.efi";

    option-data = [
      { name = "tftp-server-name"; data = tftpIp; }
      { name = "domain-search"; data = lan.domain; }
      { name = "www-server"; data = httpIp; }
      { name = "dhcp-server-identifier"; data = tftpIp; }
    ];
  }

  {
    # NOTE: Bios / non-efi
    # FIXME: Try with real hardware clients, the boot-file-name might need to be without protocol spec!
    name = "Legacy";
    test = "member('BIOS') and not (member('iPXE') or member('iPXE_COMPAT'))";
    boot-file-name = "undionly.kpxe";
    option-data = [{ name = "tftp-server-name"; data = tftpIp; }];
  }

  {
    name = "iPXE_UEFI_INCOMPAT";
    # 17 18 19 20 21 23 27 36 39
    test = "member('iPXE') and not (member('iPXE_COMPAT') or member('BIOS'))";
    boot-file-name = "http://${httpIp}/ipxe.efi";
  }

  {
    name = "iPXE_BIOS_INCOMPAT";
    # 16 17 18 19 21 23 24 25 33 34 39
    test = "member('BIOS') and member('iPXE') and not member('iPXE_COMPAT')";
    boot-file-name = "http://${httpIp}/ipxe.lkrn";
  }

  {
    name = "IPXE_CLIENTS";
    # 16 17 18 19 20 21 23 24 25 27 33 34 39
    test = "member('iPXE') or member('iPXE_COMPAT')";
    option-data = [
      { space = "ipxe"; name = "no-pxedhcp"; data = "1"; }
      # { space = "ipxe"; always-send = true; name = "keep-san"; data = "1"; }
      # { space = "ipxe"; always-send = true; name = "syslogs"; data = "syslogs.0.njk.li"; }
      # { space = "ipxe"; always-send = true; name = "cert"; data = "Arriving here like that!"; }
      # { space = "ipxe"; always-send = true; name = "version"; data = "1.2.1"; }
      # { space = "ipxe"; always-send = true; name = "username"; data = "SOMEUSER"; }
      { name = "ipxe-encap-opts"; }
      # { name = "custom-test"; data = "Custom_string"; always-send = true; }
    ];
  }
]
