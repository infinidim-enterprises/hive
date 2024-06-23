{ config, lib, pkgs, ... }:

{
  services.dunst.enable = true;
  services.dunst.settings = {
    global.font = with config.home.sessionVariables; "${HM_FONT_NAME} ${HM_FONT_SIZE}";
    global.icon_theme = "Numix-Circle";
  };
}
