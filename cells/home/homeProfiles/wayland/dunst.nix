{
  services.dunst.enable = true;
  services.dunst.settings.global = {
    # follow = "keyboard";
    enable_posix_regex = true;
    origin = "top-right";
    # offset = "(10, 30)";
    sort = "urgency_ascending";
    format = "<b>%s</b>\n%b"; # %a app_name
    frame_width = 1;
  };
}
