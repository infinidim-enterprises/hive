{ pkgs, ... }:

{
  # TODO: sops-nix for atuin key in ~/.local/share/atuin/key
  programs.atuin.enable = true;
  # NOTE: zfs - https://github.com/atuinsh/atuin/pull/2006
  # TODO: run atuin as a daemon in systemd service
  programs.atuin.package = pkgs.atuin.overrideAttrs (_: {
    # NOTE: https://github.com/Mic92/dotfiles/tree/main/home-manager/pkgs/atuin
    patches = [ ./0001-make-atuin-on-zfs-fast-again.patch ];
  });
  programs.atuin.settings = {
    dialect = "uk";
    update_check = false;
    auto_sync = true;
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
    sync.records = true;
    common_prefix = [ "sudo" "_" ];
    common_subcommands = [
      "docker"
      "git"
      "ip"
      "kubectl"
      "nix"
      "npm"
      "podman"
      "systemctl"
      "yarn"
    ];
  };
}
