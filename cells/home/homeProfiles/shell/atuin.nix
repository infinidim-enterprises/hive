{ ... }:

{
  # TODO: sops-nix for atuin key in ~/.local/share/atuin/key
  programs.atuin.enable = true;
  programs.atuin.daemon.enable = true;
  programs.atuin.settings = {
    dialect = "uk";
    update_check = false;
    auto_sync = true;
    sync_frequency = "1m";
    search_mode = "fuzzy";
    filter_mode = "workspace";
    workspaces = true;
    style = "compact";
    show_preview = true;
    secrets_filter = true;
    history_filter = [ "mkpasswd" ];
    enter_accept = false;
    keymap_mode = "emacs";
    keymap_cursor.emacs = "blink-block";
    prefers_reduced_motion = true;
    sync.records = true;
    common_prefix = [ "sudo" "_" ];
    common_subcommands = [
      "docker"
      "git"
      "ip"
      "kubectl"
      "nix"
      "nom"
      "npm"
      "podman"
      "systemctl"
      "yarn"
    ];
  };
}
