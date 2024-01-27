{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:

with lib;
let
  inherit (config.boot.kernelPackages) kernel;
  rtl88x2bu = pkgs.stdenv.mkDerivation rec {
    inherit (pkgs.sources.rtl88x2bu) pname src version;
    name = "rtl88x2bu-${kernel.version}-${version}";

    nativeBuildInputs = [ pkgs.bc ];
    buildInputs = kernel.moduleBuildDependencies;

    hardeningDisable = [ "pic" "format" ];

    prePatch = ''
      substituteInPlace ./Makefile --replace /lib/modules/ "${kernel.dev}/lib/modules/"
      substituteInPlace ./Makefile --replace '$(shell uname -r)' "${kernel.modDirVersion}"
      substituteInPlace ./Makefile --replace /sbin/depmod \#
      substituteInPlace ./Makefile --replace '$(MODDESTDIR)' "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/"
      substituteInPlace ./Makefile --replace 'CONFIG_RTW_LOG_LEVEL = 3' 'CONFIG_RTW_LOG_LEVEL = 1'
      substituteInPlace ./Makefile --replace 'CONFIG_RTW_DEBUG = y' 'CONFIG_RTW_DEBUG = n'
    '';

    preInstall = ''
      mkdir -p "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/"
    '';

    meta = with lib; {
      description = "Realtek RTL88x2BU WiFi USB Driver for Linux";
      homepage = https://github.com/RinCat/RTL88x2BU-Linux-Driver;
      license = licenses.gpl2;
      platforms = [ "x86_64-linux" "i686-linux" "aarch64-linux" ];
    };
  };
in
{
  boot.extraModulePackages = [ rtl88x2bu ];
  hardware.enableRedistributableFirmware = true;
}
