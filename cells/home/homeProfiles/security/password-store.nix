{ pkgs, lib, config, osConfig, ... }:
let
  defaultPasswordStorePath = "${config.xdg.dataHome}/password-store";
  # FIXME: isDesktop = with osConfig.services; xserver.displayManager.lightdm.enable && (pass-secret-service.enable || gnome.gnome-keyring.enable);
  isDesktop = with osConfig.services;
    xserver.displayManager.lightdm.enable; # && gnome.gnome-keyring.enable;
in
with lib;
mkMerge [
  {
    services.git-sync.enable = true;
    services.git-sync.repositories.password-store = {
      interval = 300;
      path = config.programs.password-store.settings.PASSWORD_STORE_DIR;
      uri = "keybase://private/voobofdoom/password-store";
    };
  }

  {
    services.pass-secret-service.enable = true;

    programs.password-store = {
      enable = true;
      settings.PASSWORD_STORE_DIR = mkDefault defaultPasswordStorePath;
      # settings.PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
      # settings.PASSWORD_STORE_EXTENSIONS_DIR
      package = pkgs.pass.withExtensions (exts: with exts; [
        # DEFUNCT: pass-audit
        pass-checkup
        pass-genphrase
        pass-import
        pass-otp
        pass-tomb
        pass-update
      ]);
    };
  }

  (mkIf config.programs.rofi.enable {
    programs.rofi.pass.enable = true;
    programs.rofi.pass.stores = mkDefault [ defaultPasswordStorePath ];
  })

  (mkIf isDesktop {
    home.packages = [ pkgs.gnome.seahorse ];
  })
]
