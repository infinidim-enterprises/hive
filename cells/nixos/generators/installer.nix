{ config, lib, options, modulesPath, pkgs, ... }:

{
  imports = [
    "${toString modulesPath}/profiles/all-hardware.nix"
    "${toString modulesPath}/profiles/base.nix"
    "${toString modulesPath}/profiles/clone-config.nix"
    "${toString modulesPath}/installer/cd-dvd/iso-image.nix"
    "${toString modulesPath}/installer/scan/detected.nix"
    "${toString modulesPath}/installer/scan/not-detected.nix"
    "${toString modulesPath}/installer/cd-dvd/channel.nix"
  ];

  console.packages = options.console.packages.default ++ [ pkgs.terminus_font ];

  isoImage.isoName = config.networking.hostName +
    "-install-" +
    "${pkgs.stdenv.hostPlatform.system}.iso";

  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  boot.loader.grub.memtest86.enable = false;

  # An installation media cannot tolerate a host config defined file
  # system layout on a fresh machine, before it has been formatted.
  swapDevices = lib.mkImageMediaOverride [ ];
  fileSystems = lib.mkImageMediaOverride config.lib.isoFileSystems;

  # boot.postBootCommands = ''
  #   for o in $(</proc/cmdline); do
  #     case "$o" in
  #       live.nixos.passwd=*)
  #         set -- $(IFS==; echo $o)
  #         echo "nixos:$2" | ${pkgs.shadow}/bin/chpasswd
  #         ;;
  #     esac
  #   done
  # '';

  ###
  # override installation-cd-base and enable wpa and sshd start at boot
  # systemd.services.wpa_supplicant.wantedBy = lib.mkForce [ "multi-user.target" ];
  # systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];

  ###
  system.nixos.variant_id = lib.mkDefault "installer";

  documentation.enable = false;
  documentation.nixos.enable = false;

  # Don't require sudo/root to `reboot` or `poweroff`.
  security.polkit.enable = true;

  # Enable wpa_supplicant, but don't start it by default.
  networking.wireless.enable = lib.mkDefault true;
  networking.wireless.userControlled.enable = true;
  systemd.services.wpa_supplicant.wantedBy = lib.mkOverride 50 [ ];

  environment.variables.GC_INITIAL_HEAP_SIZE = "1M";
  boot.kernel.sysctl."vm.overcommit_memory" = "1";

  # To speed up installation a little bit, include the complete
  # stdenv in the Nix store on the CD.
  system.extraDependencies = with pkgs;
    [
      stdenv
      stdenvNoCC # for runCommand
      busybox
      jq # for closureInfo
      # For boot.initrd.systemd
      makeInitrdNGTool
    ];

  boot.swraid.enable = true;
  # remove warning about unset mail
  boot.swraid.mdadmConf = "PROGRAM ${pkgs.coreutils}/bin/true";

  # Show all debug messages from the kernel but don't log refused packets
  # because we have the firewall enabled. This makes installs from the
  # console less cumbersome if the machine has a public IP.
  networking.firewall.logRefusedConnections = lib.mkDefault false;

  # Prevent installation media from evacuating persistent storage, as their
  # var directory is not persistent and it would thus result in deletion of
  # those entries.
  environment.etc."systemd/pstore.conf".text = ''
    [PStore]
    Unlink=no
  '';

  ###

  formatAttr = "isoImage";
  fileExtension = ".iso";
}
