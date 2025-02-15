{ name, pkgs, lib, config, ... }:
let
  inherit (lib)
    getExe
    concatStrings
    fileContents;

  status-format0 = [
    "#[align=left range=left #{E:status-left-style}]#[push-default]"
    "#{T;=/#{status-left-length}:status-left}#[pop-default]#[norange default]"
    "#[align=centre]#[list=on align=centre]#[list=left-marker]"
    "<#[list=right-marker]>#[list=on]#{W:#[range=window|#{window_index}"
    " #{E:window-status-style}#{?#{&&:#{window_last_flag},"
    "#{!=:#{E:window-status-last-style},default}},"
    " #{E:window-status-last-style},}#{?#{&&:#{window_bell_flag},"
    "#{!=:#{E:window-status-bell-style},default}},"
    " #{E:window-status-bell-style},#{?#{&&:#{||:#{window_activity_flag},"
    "#{window_silence_flag}},#{!=:#{E:window-status-activity-style},default}},"
    " #{E:window-status-activity-style},}}]#[push-default]"
    "#{T:window-status-format}#[pop-default]#[norange default]"
    "#{?window_end_flag,,#{window-status-separator}},"
    "#[range=window|#{window_index} list=focus #{?#{!=:#{E:window-status-current-style},default},"
    "#{E:window-status-current-style},#{E:window-status-style}}"
    "#{?#{&&:#{window_last_flag},#{!=:#{E:window-status-last-style},default}},"
    " #{E:window-status-last-style},}#{?#{&&:#{window_bell_flag},"
    "#{!=:#{E:window-status-bell-style},default}}, #{E:window-status-bell-style},"
    "#{?#{&&:#{||:#{window_activity_flag},#{window_silence_flag}},"
    "#{!=:#{E:window-status-activity-style},default}},"
    " #{E:window-status-activity-style},}}]#[push-default]"
    "#{T:window-status-current-format}#[pop-default]#[norange list=on default]"
    "#{?window_end_flag,,#{window-status-separator}}}"
    "#[nolist align=right range=right #{E:status-right-style}]#[push-default]"
    "#{T;=/#{status-right-length}:status-right}#[pop-default]#[norange default]"
  ];

  swap-pane = pkgs.writeShellApplication {
    name = "swap-pane";
    runtimeInputs = with pkgs; [
      config.programs.tmux.package
      coreutils-full
      gawk
    ];
    text = fileContents ./tmux-swap-pane.sh;
  };

  window = win_name:
    if name == "vod"
    then ''"${win_name}" "$SHELL -c 'if gpg --card-status 2>/dev/null | grep -q 77033511 && [ -d \"$HOME/Projects/hive\" ]; then cd \"$HOME/Projects/hive\"; fi; exec $SHELL'"''
    else ''"-=shell=-" "$SHELL"'';
in
{
  home.packages = [ pkgs.ansifilter ]; # for tmux logging
  programs.zsh.shellAliases = {
    tmux-default = "${getExe config.programs.tmux.package} new-session -A -s default";
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    disableConfirmationPrompt = true;
    mouse = false;
    newSession = false;
    secureSocket = true; # NOTE: perhaps should be false, to survive logouts
    baseIndex = 0;
    historyLimit = 20000;
    keyMode = "emacs";
    prefix = "C-o";
    terminal = "screen-256color";
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = tmux-colors-solarized;
        extraConfig = "set -g @colors-solarized '256'";
      }
      {
        plugin = logging;
        extraConfig = ''
          unbind l

          set -g @logging_key 'C-l'
          set -g @screen-capture-key 'l'
          set -g @save-complete-history-key 'M-l'
          set -g @clear-history-key 'M-k'

          set -g @logging-path '${config.xdg.userDirs.extraConfig.XDG_LOGS_DIR}'
          set -g @screen-capture-path '${config.xdg.userDirs.extraConfig.XDG_LOGS_DIR}'
          set -g @save-complete-history-path '${config.xdg.userDirs.extraConfig.XDG_LOGS_DIR}'
        '';
      }
      # ISSUE: https://github.com/NixOS/nixpkgs/issues/376560
      # {
      #   plugin = tmux-which-key;
      #   extraConfig = ''
      #     set -g @wk_cfg_key_prefix_table "Space"
      #     set -g @wk_cfg_title_style "align=centre,bold"
      #     set -g @wk_cfg_title_prefix "tmux"
      #     set -g @wk_cfg_title_prefix_style "fg=green,align=centre,bold"
      #     set -g @wk_cfg_pos_x "C"
      #     set -g @wk_cfg_pos_y "C"
      #   '';
      # }
    ];

    extraConfig = ''
      # Disable the startup message
      set-option -g visual-activity off
      set-option -g visual-bell off
      set-option -g visual-silence off
      set-option -g bell-action none

      # Enable automatic detach
      set-option -g detach-on-destroy off

      ${lib.optionalString config.programs.atuin.enable "set-option -g alternate-screen on"}

      # Enable the Super-key usage
      set-option -g extended-keys always

      set-option -g automatic-rename off
      set-option -g renumber-windows off
      set-option -g set-titles on

      # Set the status line
      set-option -g status on
      set-option -g status-interval 1
      set-option -g status-justify left
      set-option -g status-left-length 20
      set-option -g status-left "#[fg=green][#[fg=white]#(echo #{pane_tty} | cut -d'/' -f3-).#H#[fg=green]]"
      set-option -g status-right "#[fg=green][#[fg=white]#S#[fg=green]]"
      set-option -g status-format[0] "${concatStrings status-format0}"

      # Window list
      set-option -g window-status-format "#[fg=green]#I #W"
      set-option -g window-status-current-format "#[fg=white]#I #W"

      # copy/paste
      bind-key C-y paste-buffer

      bind-key -T copy-mode M-w      send-keys -X copy-pipe-and-cancel "copyq add - "
      bind-key -T copy-mode C-Left   send-keys -X previous-word
      bind-key -T copy-mode C-Right  send-keys -X next-word-end
      bind-key -T copy-mode M-Space  send-keys -X rectangle-toggle

      # Bind keys for window navigation
      bind-key C-o last-window
      bind-key n next-window
      bind-key p previous-window
      bind-key C-n next-window
      bind-key C-p previous-window
      bind-key k kill-pane
      bind-key K kill-window

      bind-key b run-shell "${swap-pane}/bin/swap-pane"

      # Bind prefix-m to toggle mouse mode and show a message
      bind-key m run-shell '\
        if [ "$(tmux show-option -gv mouse)" = "on" ]; then \
          tmux set-option -g mouse off; \
          tmux display-message "Mouse mode: OFF"; \
        else \
          tmux set-option -g mouse on; \
          tmux display-message "Mouse mode: ON"; \
        fi'

      # Toggle maximized state for pane
      bind-key Q if-shell -F '#{==:#{window_panes},1}' {
        display-message "Only one pane in window; nothing to maximize."
      } {
          if-shell -F '#{pane_maximized}' {
          resize-pane -Z
      } {
          resize-pane -Z
        }
      }

      # Bind keys for splitting panes
      bind-key "\\" split-window -v
      bind-key "|" split-window -h

      # Bind keys for resizing panes
      bind-key -n M-J resize-pane -L 1
      bind-key -n M-L resize-pane -R 1
      bind-key -n M-I resize-pane -U 1
      bind-key -n M-K resize-pane -D 1

      # Bind keys for focusing panes
      # bind-key -n M-Return select-pane -t :.+
      bind-key -n M-j select-pane -L
      bind-key -n M-l select-pane -R
      bind-key -n M-i select-pane -U
      bind-key -n M-k select-pane -D

      # Bind other keys
      bind-key A command-prompt -I "#W" "rename-window '%%'"
      bind-key q kill-session

      # Bind keys for logging
      bind-key R new-window -n "-=root=-" "sudo su -"
      bind-key L new-window -n "-=syslog=-" "journalctl -fn -l -q"
      bind-key D new-window -n "-=docker-stats=-" "docker-ps"
      bind-key P new-window -n "-=top=-" "${pkgs.btop}/bin/btop"

      # Create initial session and windows
      new-session -s default -n ${window "-=flake=-"}
      new-window -t default -n "-=syslog=-" "journalctl -fn -l -q"
      new-window -t default -n "-=top=-" "${pkgs.btop}/bin/btop"
      new-window -t default -n ${window "-=repl=-"}
      new-window -t default -n "misc" "$SHELL"

      # Select the first window
      select-window -t default:0
    '';
  };
}
/*
  bind-key -T copy-mode Escape            send-keys -X cancel
  bind-key -T copy-mode Space             send-keys -X page-down
  bind-key -T copy-mode ,                 send-keys -X jump-reverse
  bind-key -T copy-mode \;                send-keys -X jump-again
  bind-key -T copy-mode F                 command-prompt -1 -p "(jump backward)" { send-keys -X jump-backward "%%" }
  bind-key -T copy-mode N                 send-keys -X search-reverse
  bind-key -T copy-mode P                 send-keys -X toggle-position
  bind-key -T copy-mode T                 command-prompt -1 -p "(jump to backward)" { send-keys -X jump-to-backward "%%" }
  bind-key -T copy-mode X                 send-keys -X set-mark
  bind-key -T copy-mode f                 command-prompt -1 -p "(jump forward)" { send-keys -X jump-forward "%%" }
  bind-key -T copy-mode g                 command-prompt -p "(goto line)" { send-keys -X goto-line "%%" }
  bind-key -T copy-mode n                 send-keys -X search-again
  bind-key -T copy-mode q                 send-keys -X cancel
  bind-key -T copy-mode r                 send-keys -X refresh-from-pane
  bind-key -T copy-mode t                 command-prompt -1 -p "(jump to forward)" { send-keys -X jump-to-forward "%%" }
  bind-key -T copy-mode MouseDown1Pane    select-pane
  bind-key -T copy-mode MouseDrag1Pane    select-pane \; send-keys -X begin-selection
  bind-key -T copy-mode MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel
  bind-key -T copy-mode WheelUpPane       select-pane \; send-keys -X -N 5 scroll-up
  bind-key -T copy-mode WheelDownPane     select-pane \; send-keys -X -N 5 scroll-down
  bind-key -T copy-mode DoubleClick1Pane  select-pane \; send-keys -X select-word \; run-shell -d 0.3 \; send-keys -X copy-pipe-and-cancel
  bind-key -T copy-mode TripleClick1Pane  select-pane \; send-keys -X select-line \; run-shell -d 0.3 \; send-keys -X copy-pipe-and-cancel
  bind-key -T copy-mode Home              send-keys -X start-of-line
  bind-key -T copy-mode End               send-keys -X end-of-line
  bind-key -T copy-mode NPage             send-keys -X page-down
  bind-key -T copy-mode PPage             send-keys -X page-up
  bind-key -T copy-mode Up                send-keys -X cursor-up
  bind-key -T copy-mode Down              send-keys -X cursor-down
  bind-key -T copy-mode Left              send-keys -X cursor-left
  bind-key -T copy-mode Right             send-keys -X cursor-right
  bind-key -T copy-mode M-1               command-prompt -N -I 1 -p (repeat) { send-keys -N "%%" }
  bind-key -T copy-mode M-2               command-prompt -N -I 2 -p (repeat) { send-keys -N "%%" }
  bind-key -T copy-mode M-3               command-prompt -N -I 3 -p (repeat) { send-keys -N "%%" }
  bind-key -T copy-mode M-4               command-prompt -N -I 4 -p (repeat) { send-keys -N "%%" }
  bind-key -T copy-mode M-5               command-prompt -N -I 5 -p (repeat) { send-keys -N "%%" }
  bind-key -T copy-mode M-6               command-prompt -N -I 6 -p (repeat) { send-keys -N "%%" }
  bind-key -T copy-mode M-7               command-prompt -N -I 7 -p (repeat) { send-keys -N "%%" }
  bind-key -T copy-mode M-8               command-prompt -N -I 8 -p (repeat) { send-keys -N "%%" }
  bind-key -T copy-mode M-9               command-prompt -N -I 9 -p (repeat) { send-keys -N "%%" }
  bind-key -T copy-mode M-<               send-keys -X history-top
  bind-key -T copy-mode M->               send-keys -X history-bottom
  bind-key -T copy-mode M-R               send-keys -X top-line
  bind-key -T copy-mode M-m               send-keys -X back-to-indentation
  bind-key -T copy-mode M-r               send-keys -X middle-line
  bind-key -T copy-mode M-v               send-keys -X page-up
  bind-key -T copy-mode M-x               send-keys -X jump-to-mark
  bind-key -T copy-mode "M-{"             send-keys -X previous-paragraph
  bind-key -T copy-mode "M-}"             send-keys -X next-paragraph
  bind-key -T copy-mode M-Up              send-keys -X halfpage-up
  bind-key -T copy-mode M-Down            send-keys -X halfpage-down
  bind-key -T copy-mode C-Space           send-keys -X begin-selection
  bind-key -T copy-mode C-a               send-keys -X start-of-line
  bind-key -T copy-mode C-b               send-keys -X cursor-left
  bind-key -T copy-mode C-c               send-keys -X cancel
  bind-key -T copy-mode C-e               send-keys -X end-of-line
  bind-key -T copy-mode C-f               send-keys -X cursor-right
  bind-key -T copy-mode C-g               send-keys -X clear-selection
  bind-key -T copy-mode C-k               send-keys -X copy-pipe-end-of-line-and-cancel
  bind-key -T copy-mode C-n               send-keys -X cursor-down
  bind-key -T copy-mode C-p               send-keys -X cursor-up
  bind-key -T copy-mode C-r               command-prompt -i -I "#{pane_search_string}" -T search -p "(search up)" { send-keys -X search-backward-incremental "%%" }
  bind-key -T copy-mode C-s               command-prompt -i -I "#{pane_search_string}" -T search -p "(search down)" { send-keys -X search-forward-incremental "%%" }
  bind-key -T copy-mode C-v               send-keys -X page-down
  bind-key -T copy-mode C-w               send-keys -X copy-pipe-and-cancel
  bind-key -T copy-mode C-Up              send-keys -X scroll-up
  bind-key -T copy-mode C-Down            send-keys -X scroll-down
  bind-key -T copy-mode C-M-b             send-keys -X previous-matching-bracket
  bind-key -T copy-mode C-M-f             send-keys -X next-matching-bracket
*/
