{ pkgs, ... }:

{
  # TODO: sops-nix for atuin key in ~/.local/share/atuin
  programs.atuin.enable = true;
  programs.atuin.settings = {
    # FIXME: zfs - https://github.com/atuinsh/atuin/pull/2006
    sync_frequency = "1m";
    search_mode = "fuzzy";
    filter_mode = "global";
    workspaces = true;
    style = "compact";
    show_preview = true;
    secrets_filter = true;
    history_filter = [ "mkpasswd" ];
    enter_accept = false;
    keymap_mode = "emacs";
    keymap_cursor.emacs = "blink-block";
    prefers_reduced_motion = true;
    common_prefix = [ "sudo" ];
  };
}
