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
    text = lib.fileContents ./tmux-swap-pane.sh;
  };
in
{
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
    plugins = with pkgs.tmuxPlugins; [{
      plugin = tmux-colors-solarized;
      extraConfig = "set -g @colors-solarized '256'";
    }];

    extraConfig = ''
      # FIXME: 'invalid option utf8' set -g utf8 on

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
      # set-option -g status-right-length 50
      set-option -g status-style fg=white,bg=black
      set-option -g status-left "#[fg=green][#[fg=white]#(echo #{pane_tty} | cut -d'/' -f3-).#H#[fg=green]]"
      set-option -g status-right "#[fg=green][#[fg=white]#S#[fg=green]]"
      # Status format
      set-option -g status-format[0] "${concatStrings status-format0}"

      # Window list
      set-option -g window-status-format "#I #W"
      set-option -g window-status-current-format "#[fg=white]#I #W"

      # Bind keys for copying and pasting
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind-key -T copy-mode-vi Y send-keys -X copy-pipe-and-cancel "xsel -i -b"
      bind-key -T copy-mode-vi p send-keys -X paste-buffer

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
          display-message "Pane restored to original size."
      } {
          resize-pane -Z
          display-message "Pane maximized."
        }
      }

      # Bind keys for splitting panes emacs-style
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
      bind-key P new-window -n "-=top=-" "${pkgs.btop}/bin/btop --low-color"

      # Create initial session and windows
      new-session -s default -n "-=flake=-" "$SHELL"
      new-window -t default -n "-=syslog=-" "journalctl -fn -l -q"
      new-window -t default -n "-=top=-" "btop --low-color"
      new-window -t default -n "src" "$SHELL"
      new-window -t default -n "misc" "$SHELL"

      # Select the first window
      select-window -t default:0
    '';
  };
}
