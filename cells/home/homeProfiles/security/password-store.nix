{ pkgs, lib, config, osConfig, localLib, ... }:
let
  defaultPasswordStorePath = "${config.xdg.dataHome}/password-store";
  inherit (lib)
    mkDefault
    mkMerge
    mkIf;
in

mkMerge [
  {
    services.git-sync.enable = true;
    services.git-sync.repositories.password-store = {
      interval = 300;
      path = config.programs.password-store.settings.PASSWORD_STORE_DIR;
      uri = "keybase://private/voobofdoom/password-store"; # TODO: [keybase uri] per user
      extraPackages = [ pkgs.kbfs ];
    };
  }

  {
    # NOTE: https://github.com/grimsteel/pass-secret-service
    services.pass-secret-service.enable = true;
    services.pass-secret-service.storePath = config.programs.password-store.settings.PASSWORD_STORE_DIR;

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
        pass-file
        pass-otp
        pass-tomb
        pass-update
      ]);
    };
  }

  (mkIf config.programs.rofi.enable {
    programs.rofi.pass.enable = true;
    programs.rofi.pass.stores = [ config.programs.password-store.settings.PASSWORD_STORE_DIR ];
  })

  (mkIf (localLib.isGui osConfig) {
    home.packages = [ pkgs.seahorse ];
  })
]
