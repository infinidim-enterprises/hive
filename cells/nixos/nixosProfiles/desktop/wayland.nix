{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
let
  inherit (lib // builtins)
    mkIf
    mkMerge
    hasAttr;
in
mkMerge [
  (mkIf (hasAttr "home-manager" config) {
    home-manager.sharedModules = [

    ];
  })
  {
    # programs.hyprland.package
    # programs.hyprland.portalPackage

    # imports = [ ];

    programs.hyprland.enable = true;
    # BUG: https://github.com/NixOS/nixpkgs/issues/320734
    # programs.hyprland.systemd.setPath.enable = true;
    programs.hyprland.systemd.setPath.enable = false;
    systemd.user.extraConfig = ''
      DefaultEnvironment="PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:$PATH"
    '';

    programs.hyprland.xwayland.enable = true;

    services.hypridle.enable = true;
    programs.hyprlock.enable = true;

    programs.xwayland.enable = true;
    xdg.portal.enable = true;
    xdg.portal.wlr.enable = true;

    # xdg.portal.extraPortals = with pkgs;[
    #   xdg-desktop-portal-gtk
    #   xdg-desktop-portal-gnome
    #   xdg-desktop-portal-xapp
    #   xdg-desktop-portal-shana
    # ];

    ### TODO: hyprland plugins:
    # https://github.com/jasper-at-windswept/hypr-ws-switcher
    # https://github.com/codelif/hyprnotify
    # https://github.com/zakk4223/hyprNStack
    # https://github.com/shezdy/hyprsplit
    # https://github.com/JoaoCostaIFG/hyprtags
    # https://github.com/VortexCoyote/hyprfocus
    # https://github.com/horriblename/hyprgrass
    # https://github.com/DreamMaoMao/hycov
    ###
    # hyprctl output create headless test
    # https://wiki.hyprland.org/Configuring/Using-hyprctl/#commands

    environment.systemPackages = with pkgs; [
      wev

      grim

      wofi
      wtype
      wofi-pass
      wofi-emoji
      wl-clipboard

      kitty
      waybar
      networkmanagerapplet
      wayvnc
    ];

    programs.waybar.enable = true;
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
