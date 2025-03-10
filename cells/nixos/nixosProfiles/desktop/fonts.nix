{ inputs, cell, ... }:

{ pkgs, lib, config, ... }:
let
  inherit (lib) mkMerge mkIf;
in
mkMerge [
  {
    fonts.fontDir.enable = true;
    fonts.enableGhostscriptFonts = true;
    fonts.packages = with pkgs;
      [
        # (nerdfonts.override (_: {
        #   fonts = [
        #     "InconsolataLGC"
        #     "Ubuntu"
        #     "DejaVuSansMono"
        #     "DroidSansMono"
        #     "JetBrainsMono"
        #     "ShareTechMono"
        #     "UbuntuMono"
        #     "VictorMono"
        #   ];
        # }))

        dejavu_fonts
        roboto
        freefont_ttf
        tlwg
        corefonts
        terminus_font
        material-icons
        weather-icons
        inputs.cells.emacs.packages.all-the-icons
        material-symbols
      ] ++ (with pkgs.nerd-fonts; [
        inconsolata-lgc
        ubuntu
        ubuntu-mono
        ubuntu-sans
        dejavu-sans-mono
        droid-sans-mono
        jetbrains-mono
        shure-tech-mono
        victor-mono
      ]) ++ [ inputs.cells.common.packages.windows-fonts ];

    fonts.fontconfig = {
      enable = true;
      antialias = true;
      hinting.enable = true;
      hinting.autohint = true;
      defaultFonts = {
        monospace = [ "UbuntuMono Nerd Font Mono" ];
        sansSerif = [ "UbuntuMono Nerd Font Mono" ];
        serif = [ "UbuntuMono Nerd Font Mono" ];
      };
    };
  }

  (mkIf config.fonts.fontDir.enable {
    systemd.user.services.clean-cache-fontconfig = {
      # NOTE: https://github.com/NixOS/nixpkgs/issues/204181
      documentation = [ "https://github.com/NixOS/nixpkgs/issues/204181" ];
      partOf = [ "basic.target" ];
      before = [ "graphical-session.target" ];
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = "yes";
      serviceConfig.SyslogIdentifier = "rm-cache-fontconfig";
      scriptArgs = "%h";
      script = ''
        rm -rf "''${1}/.cache/fontconfig"
      '';
    };
  })
]
