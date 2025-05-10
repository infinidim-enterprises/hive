{ stdenv #
, buildPackages
, lib #
, sources #
, perl #
, cdrkit
, xorriso #
, xz #
, openssl #
, gnu-efi #
, mtools #
, syslinux ? null #
, embedScript ? null
, embedTrust ? null
, embedCert ? null
, additionalTargets ? { }
}:

let
  # https://ipxe.org/appnote/buildtargets
  targets = additionalTargets // lib.optionalAttrs stdenv.isx86_64 {
    "bin-x86_64-efi/ipxe.efi" = null;
    "bin-x86_64-efi/ipxe.efidrv" = null;
    "bin-x86_64-efi/ipxe.efirom" = null;
    "bin-x86_64-efi/snponly.efi" = null;
    "bin-x86_64-efi/ipxe.usb" = "ipxe-efi.usb";

    # Rarely, but those things happen
    # especially on cherrytrail/baytrail platforms
    # also older uefi implementations
    "bin-i386-efi/ipxe.efi" = "ipxe32.efi";
    "bin-i386-efi/ipxe.efidrv" = "ipxe32.efidrv";
    "bin-i386-efi/ipxe.efirom" = "ipxe32.efirom";
    "bin-i386-efi/snponly.efi" = "ipxe32-snponly.efi";
    "bin-i386-efi/ipxe.usb" = "ipxe32-efi.usb";
  } // lib.optionalAttrs stdenv.hostPlatform.isx86 {
    "bin/ipxe.dsk" = null;
    "bin/ipxe.usb" = null;
    "bin/ipxe.iso" = null;
    "bin/ipxe.lkrn" = null;
    "bin/undionly.kpxe" = null;
  } // lib.optionalAttrs stdenv.isAarch32 {
    "bin-arm32-efi/ipxe.efi" = null;
    "bin-arm32-efi/ipxe.efirom" = null;
    "bin-arm32-efi/ipxe.usb" = "ipxe-efi.usb";
  } // lib.optionalAttrs stdenv.isAarch64 {
    "bin-arm64-efi/ipxe.efi" = null;
    "bin-arm64-efi/ipxe.efirom" = null;
    "bin-arm64-efi/ipxe.usb" = "ipxe-efi.usb";
  };
in

stdenv.mkDerivation rec {
  inherit (sources.ipxe) pname version src;

  nativeBuildInputs = [
    perl #
    cdrkit
    xorriso #
    xz #
    openssl #
    gnu-efi #
    mtools #
  ] ++ lib.optional stdenv.hostPlatform.isx86 syslinux;

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  strictDeps = true;

  postPatch = lib.optionalString stdenv.hostPlatform.isAarch64 ''
    substituteInPlace src/util/genfsimg --replace "	syslinux " "	true "
  ''; # calling syslinux on a FAT image isn't going to work

  hardeningDisable = [ "pic" "stackprotector" ];

  NIX_CFLAGS_COMPILE = "-Wno-error";

  makeFlags =
    [
      "ECHO_E_BIN_ECHO=echo"
      "ECHO_E_BIN_ECHO_E=echo"
      "CROSS=${stdenv.cc.targetPrefix}"
    ]
    ++ lib.optionals stdenv.hostPlatform.isx86 [
      "ISOLINUX_BIN_LIST=${syslinux}/share/syslinux/isolinux.bin"
      "LDLINUX_C32=${syslinux}/share/syslinux/ldlinux.c32"
    ]
    ++ lib.optional (embedScript != null) "EMBED=${embedScript}"
    ++ lib.optional (embedTrust != null) "TRUST=${embedTrust}"
    ++ lib.optional (embedCert != null) "CERT=${embedCert}";

  consoleOptions = [
    "CONSOLE_FRAMEBUFFER"
    "CONSOLE_SYSLOG"
  ];

  brandingOptions = [
    # "PRODUCT_NAME \"iPXE - NixOS ${config.system.nixos.codeName} - ${config.system.nixos.release}\""
    # "PRODUCT_SHORT_NAME \"${userClassString}\""
    "PRODUCT_TAG_LINE \"Thanks for all the fish!\""
    "PRODUCT_URI \"http://info.njk.local\""
  ];

  enabledOptions = [
    # "BANNER_TIMEOUT 150"
    # "ROM_BANNER_TIMEOUT 0"

    "DOWNLOAD_PROTO_HTTP"
    "DOWNLOAD_PROTO_HTTPS"
    "DOWNLOAD_PROTO_FTP"
    "DOWNLOAD_PROTO_SLAM"
    "DOWNLOAD_PROTO_NFS"
    "DOWNLOAD_PROTO_FILE"

    "SANBOOT_PROTO_ISCSI"
    "SANBOOT_PROTO_AOE"
    # "SANBOOT_PROTO_IB_SRP"
    # "SANBOOT_PROTO_FCP"
    "SANBOOT_PROTO_HTTP"

    "HTTP_AUTH_NTLM"
    # "HTTP_ENC_PEERDIST"

    # "IMAGE_NBI"
    # "IMAGE_ELF"
    # "IMAGE_MULTIBOOT"
    # "IMAGE_PXE"

    "IMAGE_SCRIPT"

    # "IMAGE_BZIMAGE"
    # "IMAGE_COMBOOT"
    # "IMAGE_EFI"
    # "IMAGE_SDI"

    "IMAGE_PNG"
    "IMAGE_DER"
    "IMAGE_PEM"
    "IMAGE_ZLIB"
    "IMAGE_GZIP"

    "IMAGE_TRUST_CMD"
    "NSLOOKUP_CMD"
    "TIME_CMD"
    "DIGEST_CMD"
    "VLAN_CMD"
    # ISSUE: pkg doesn't build with this enabled - "PXE_CMD"
    "REBOOT_CMD"
    "POWEROFF_CMD"
    "PCI_CMD"
    "PARAM_CMD"
    "NEIGHBOUR_CMD"
    "PING_CMD"
    "CONSOLE_CMD"
    "IPSTAT_CMD"
    "NTP_CMD"
    "CERT_CMD"
    "IMAGE_MEM_CMD"

    # "NONPNP_HOOK_INT19"

    # "BUILD_SERIAL"
    # "BUILD_ID"
  ];

  configurePhase = ''
    runHook preConfigure
    for opt in ${lib.escapeShellArgs enabledOptions}; do echo "#define $opt" >> src/config/local/general.h; done
    for opt in ${lib.escapeShellArgs brandingOptions}; do echo "#define $opt" >> src/config/local/branding.h; done
    for opt in ${lib.escapeShellArgs consoleOptions}; do echo "#define $opt" >> src/config/local/console.h; done
    substituteInPlace src/Makefile.housekeeping --replace '/bin/echo' echo
    substituteInPlace src/util/genfsimg --replace '/usr/share/syslinux' '${syslinux}/share/syslinux'
    substituteInPlace src/net/udp/dhcp.c --replace '/* for PXE */' '4, 33, 42, 72, /* for PXE */'
    runHook postConfigure
  '';

  preBuild = "cd src";

  buildFlags = lib.attrNames targets;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (from: to:
      if to == null
      then "cp -v ${from} $out"
      else "cp -v ${from} $out/${to}") targets)}

    # Some PXE constellations especially with dnsmasq are looking for the file with .0 ending
    # let's provide it as a symlink to be compatible in this case.
    ln -s undionly.kpxe $out/undionly.kpxe.0

    runHook postInstall
  '';

  enableParallelBuilding = true;
}
