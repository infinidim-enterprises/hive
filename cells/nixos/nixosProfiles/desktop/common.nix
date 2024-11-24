{ inputs, cell, ... }:

{ pkgs, lib, config, ... }:

let
  inherit (lib) mkMerge mkIf;
in
mkMerge [
  # (mkIf {

  #   services.redshift.enable = true;
  #   # services.redshift.brightness.day = "10";
  #   services.redshift.temperature.day = 4200;
  #   # services.redshift.brightness.night = "10";
  #   services.redshift.temperature.night = 3600;

  # })

  {
    home-manager.sharedModules = [
      {
        programs.zsh.enableVteIntegration = true;
        programs.bash.enableVteIntegration = true;
      }
      ({ osConfig, ... }: mkIf osConfig.programs.kdeconnect.enable {
        services.kdeconnect.enable = true;
        services.kdeconnect.indicator = true;
      })
    ];

    services.displayManager.logToFile = false;
    services.displayManager.logToJournal = false;
    security.polkit.enable = true;
    # security.pam.services.login.enableGnomeKeyring = lib.mkForce false;

    programs.nix-ld.enable = true;
    programs.droidcam.enable = true;

    programs.kdeconnect.enable = true; # NOTE: open firewall ports 1714-1764
    programs.kdeconnect.package = pkgs.plasma5Packages.kdeconnect-kde;

    xdg.mime.enable = true;

    programs.light.enable = true;
    programs.light.brightnessKeys.enable = true;

    hardware.sane.enable = true;
    hardware.acpilight.enable = true;

    hardware.pulseaudio.enable = true;
    services.pipewire.enable = false;

    services.opensnitch.enable = false; # NOTE: opensnitch SUCKS!

    services.colord.enable = true;
    # services.devmon.enable = true;
    services.gvfs.enable = true;
    services.udisks2.enable = true;
    services.accounts-daemon.enable = true;
    services.packagekit.enable = true;
    services.gnome.gnome-keyring.enable = lib.mkForce false;
    services.gnome.at-spi2-core.enable = true;
    services.gnome.glib-networking.enable = true;

    programs.system-config-printer.enable = true;

    environment.systemPackages = with pkgs; [
      pulseaudio-ctl
      pamixer
      pavucontrol

      adwaita-icon-theme
      dconf-editor

      numix-cursor-theme
      numix-icon-theme-circle
      numix-icon-theme
      numix-solarized-gtk-theme

      libnotify

      desktop-file-utils
      shared-mime-info
      xdg-user-dirs

      # Misc utils
      xfontsel
      xdotool
      xsel
      evtest
    ];
  }
]
