{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
let
  inherit (lib // builtins)
    mkIf
    mkMerge
    hasAttr;
  global = {
    "usershare path" = "/var/lib/samba/usershares";
    "usershare max shares" = "100";
    "usershare allow guests" = "yes";
    "usershare owner only" = "yes";
    "disable netbios" = "yes";
    "smb ports" = "445";
  };
  extraConfig =
    with lib;
    "\n" +
    (concatStringsSep "\n"
      (mapAttrsToList (k: v: "${toString k} = ${toString v}")
        global)) +
    "\n";
  post_24-05 = lib.versionOlder inputs.nixos-24-05.lib.version pkgs.lib.version;
in
mkMerge [
  (mkIf post_24-05 {
    services.samba.settings = { inherit global; };
    services.samba.nmbd.enable = false;
  })
  (mkIf (!post_24-05) {
    services.samba = {
      inherit extraConfig;
      enableNmbd = false;
    };
  })

  {
    # NOTE: caja will be able to use net usershare
    services.samba.enable = true;
    services.samba.package = pkgs.sambaFull;
    services.samba.openFirewall = true;

    systemd.services.samba-smbd.serviceConfig.ExecStartPre = "${pkgs.coreutils}/bin/mkdir -m +t -p /var/lib/samba/usershares";
  }

  {
    # TODO: upower - /org/freedesktop/UPower
    services.upower.enable = true;

    programs.hyprland.enable = true;
    programs.hyprland.withUWSM = true;

    # programs.uwsm.enable = true;
    # programs.uwsm.waylandCompositors = {
    #   hyprland =
    #     let
    #       inherit (lib) concatStringsSep;
    #       cmd = [
    #         "${pkgs.dbus}/bin/dbus-update-activation-environment"
    #         "--systemd"
    #         "--all"
    #         "&&"
    #         "${config.programs.hyprland.package}/bin/Hyprland"
    #       ];
    #       hyprlandScript = pkgs.writeScriptBin "hyprland" ''
    #         ${pkgs.bash}/bin/bash -l -c '${concatStringsSep " " cmd}'
    #       '';
    #     in
    #     {
    #       prettyName = "Hyprland";
    #       comment = "Hyprland compositor managed by UWSM";
    #       binPath = "${hyprlandScript}/bin/hyprland";
    #     };
    # };

    programs.hyprland.xwayland.enable = true;
    programs.hyprland.systemd.setPath.enable = true;

    programs.xwayland.enable = true;
    security.pam.services.hyprlock = { };

    xdg.portal.enable = true;
    xdg.portal.config.common.default = [ "hyprland;gtk" ];

    ### TODO: hyprland plugins:
    # https://github.com/jasper-at-windswept/hypr-ws-switcher
    # https://github.com/codelif/hyprnotify
    # https://github.com/zakk4223/hyprNStack
    # https://github.com/shezdy/hyprsplit
    # https://github.com/JoaoCostaIFG/hyprtags
    # https://github.com/VortexCoyote/hyprfocus
    # https://github.com/horriblename/hyprgrass
    # https://gitlab.com/magus/hyprslidr
    ###
    # hyprctl output create headless test
    # https://wiki.hyprland.org/Configuring/Using-hyprctl/#commands

    environment.systemPackages = with pkgs; [
      wev

      # nitch # system fetch # TODO: https://github.com/ssleert/nitch/pull/20
      grim # wayland screenshot
      slurp # Select a region in a Wayland compositor
      grimblast
      swappy
      # hyprpicker

      wofi
      wtype
      wofi-pass
      wofi-emoji

      wlogout
      wl-clipboard
      wlrctl

      kitty
      wayvnc
      freerdp3 # wlfreerdp

      hdrop
      hyprprop

      glib
      polkit_gnome
      gtk4-layer-shell # Lib
      walker # launcher https://github.com/abenz1267/walker TODO: home-manager module for walker

      /*

      walker.url = "github:abenz1267/walker";
      walker.inputs.nixpkgs.follows = "nixpkgs-unstable";

      */
    ];

  }
]
/*
  Hyprland is a dynamic tiling Wayland compositor that supports advanced configurations and is capable of handling multiple displays, including virtual displays streamed via RDP. While Hyprland itself does not natively support RDP or VNC, you can achieve similar functionality by using auxiliary tools like WayVNC or RDP backends. Here is how you can set up a configuration with Hyprland, where the middle display is a local physical screen, and the left and right ones are streamed via RDP:

  ### Steps to Set Up Multiple Virtual Displays with Hyprland

  1. **Install Necessary Packages**:
   On the server, install Hyprland, WayVNC (since RDP directly isn't supported), and other necessary tools:
   ```sh
   sudo apt update
   sudo apt install hyprland wayvnc
   ```

  2. **Configure Hyprland**:
   Create or edit the Hyprland configuration file, typically located at `~/.config/hypr/hyprland.conf`. Configure the physical and virtual displays.

   Example configuration:
   ```ini
   monitor=HDMI-A-1,1920x1080,0x0,1
   monitor=VNC-1,1920x1080,1920x0,1
   monitor=VNC-2,1920x1080,-1920x0,1
   ```

   This configuration sets up:
   - `HDMI-A-1`: The physical display in the middle.
   - `VNC-1`: The virtual display on the right.
   - `VNC-2`: The virtual display on the left.

  3. **Start Hyprland**:
   Start Hyprland normally:
   ```sh
   hyprland
   ```

  4. **Start WayVNC Sessions**:
   On the server, start WayVNC instances for the virtual displays. Note that you need to set the display environment variable properly to target each VNC session.

   ```sh
   WAYLAND_DISPLAY=wayland-0 wayvnc -C /path/to/cert.pem -K /path/to/key.pem
   WAYLAND_DISPLAY=wayland-1 wayvnc -C /path/to/cert.pem -K /path/to/key.pem
   ```

   Ensure you have the necessary certificates and keys for secure connections.

  5. **Connect with VNC Clients**:
   On the client machines, use VNC clients to connect to the server’s IP address. You will need two separate VNC clients to connect to the VNC sessions.

   For example, using `tigervnc`:
   ```sh
   vncviewer server_ip:5900
   vncviewer server_ip:5901
   ```

   Adjust the ports (`5900`, `5901`, etc.) as necessary.

  ### Summary

  This configuration involves setting up Hyprland with one physical display and two virtual displays using WayVNC. You will configure Hyprland to handle multiple monitors, start Hyprland, and then start WayVNC instances for each virtual display. Connect to these virtual displays using VNC clients from other machines.

  While this setup does not use RDP directly (since Hyprland does not have native RDP support), it achieves similar functionality using VNC. If RDP is a strict requirement, you might need to explore additional solutions or different Wayland compositors that support RDP more directly, such as Weston.
*/

/*
  Nov 25 11:45:46 oglaroon systemd[4354]: Starting Portal service...
  Nov 25 11:45:46 oglaroon .xdg-desktop-po[4516]: Choosing gtk.portal for org.freedesktop.impl.portal.Lockdown as a last-resort fallback
  Nov 25 11:45:46 oglaroon .xdg-desktop-po[4516]: The preferred method to match portal implementations to desktop environments is to use the portals.conf(5) configuration file
  Nov 25 11:46:11 oglaroon .xdg-desktop-po[4516]: No skeleton to export
  Nov 25 11:46:11 oglaroon .xdg-desktop-po[4516]: Choosing gtk.portal for org.freedesktop.impl.portal.FileChooser as a last-resort fallback
  Nov 25 11:46:36 oglaroon .xdg-desktop-po[4516]: Failed to create file chooser proxy: Error calling StartServiceByName for org.freedesktop.impl.portal.desktop.gtk: Timeout was reached
  Nov 25 11:46:36 oglaroon .xdg-desktop-po[4516]: No skeleton to export
  Nov 25 11:46:36 oglaroon .xdg-desktop-po[4516]: Choosing gtk.portal for org.freedesktop.impl.portal.AppChooser as a last-resort fallback
  Nov 25 11:47:01 oglaroon .xdg-desktop-po[4516]: Failed to create app chooser proxy: Error calling StartServiceByName for org.freedesktop.impl.portal.desktop.gtk: Timeout was reached
  Nov 25 11:47:01 oglaroon .xdg-desktop-po[4516]: No skeleton to export
  Nov 25 11:47:01 oglaroon .xdg-desktop-po[4516]: Choosing gtk.portal for org.freedesktop.impl.portal.Print as a last-resort fallback
  Nov 25 11:47:16 oglaroon systemd[4354]: xdg-desktop-portal.service: start operation timed out. Terminating.
  Nov 25 11:47:16 oglaroon systemd[4354]: xdg-desktop-portal.service: Failed with result 'timeout'.
  Nov 25 11:47:16 oglaroon systemd[4354]: Failed to start Portal service.
  Nov 25 11:53:08 oglaroon systemd[4354]: Starting Portal service...
  Nov 25 11:53:08 oglaroon .xdg-desktop-po[9368]: Choosing gtk.portal for org.freedesktop.impl.portal.Lockdown as a last-resort fallback
  Nov 25 11:53:08 oglaroon .xdg-desktop-po[9368]: The preferred method to match portal implementations to desktop environments is to use the portals.conf(5) configuration file
  Nov 25 11:53:08 oglaroon .xdg-desktop-po[9368]: No skeleton to export
  Nov 25 11:53:08 oglaroon .xdg-desktop-po[9368]: Choosing gtk.portal for org.freedesktop.impl.portal.FileChooser as a last-resort fallback
  Nov 25 11:53:08 oglaroon .xdg-desktop-po[9368]: Choosing gtk.portal for org.freedesktop.impl.portal.AppChooser as a last-resort fallback
  Nov 25 11:53:08 oglaroon .xdg-desktop-po[9368]: Choosing gtk.portal for org.freedesktop.impl.portal.Print as a last-resort fallback
  Nov 25 11:53:08 oglaroon .xdg-desktop-po[9368]: Choosing gtk.portal for org.freedesktop.impl.portal.Notification as a last-resort fallback
  Nov 25 11:53:08 oglaroon .xdg-desktop-po[9368]: Choosing gtk.portal for org.freedesktop.impl.portal.Inhibit as a last-resort fallback
  Nov 25 11:53:08 oglaroon .xdg-desktop-po[9368]: Choosing gtk.portal for org.freedesktop.impl.portal.Access as a last-resort fallback
  Nov 25 11:53:08 oglaroon .xdg-desktop-po[9368]: Failed connect to PipeWire: Couldn't connect to PipeWire
  Nov 25 11:53:08 oglaroon .xdg-desktop-po[9368]: Choosing gtk.portal for org.freedesktop.impl.portal.Wallpaper as a last-resort fallback
  Nov 25 11:53:08 oglaroon .xdg-desktop-po[9368]: Choosing gtk.portal for org.freedesktop.impl.portal.Account as a last-resort fallback
  Nov 25 11:53:08 oglaroon .xdg-desktop-po[9368]: Choosing gtk.portal for org.freedesktop.impl.portal.Email as a last-resort fallback
  Nov 25 11:53:08 oglaroon .xdg-desktop-po[9368]: Choosing gtk.portal for org.freedesktop.impl.portal.DynamicLauncher as a last-resort fallback

*/
