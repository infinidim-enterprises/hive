{ name, pkgs, lib, config, ... }:

{
  programs.tmux = {
    enable = true;
    clock24 = true;
    disableConfirmationPrompt = true;
    mouse = true;
    newSession = true;
    secureSocket = true; # NOTE: perhaps should be false, to survive logouts
    baseIndex = 0;
    historyLimit = 20000;
    keyMode = "emacs";
    prefix = "C-o";
    terminal = "screen-256color";
    plugins = with pkgs.tmuxPlugins; [
      tmux-colors-solarized
    ];

    extraConfig = ''
      set-option -g utf8 on

      # Disable the startup message
      set-option -g visual-activity off
      set-option -g visual-bell off
      set-option -g visual-silence off
      set-option -g bell-action none

      # Enable automatic detach
      set-option -g detach-on-destroy off

      # Enable alternate screen
      ${lib.optionalString config.programs.atuin.enable "set-option -g alternate-screen on"}

      # Set the escape key to Ctrl-O
      set-option -g prefix C-o
      unbind-key C-b
      bind-key C-o send-prefix

      # Enable mouse support
      set-option -g mouse on

      # Set the status line
      set-option -g status on
      set-option -g status-interval 1
      set-option -g status-justify left
      set-option -g status-left-length 20
      set-option -g status-right-length 50
      set-option -g status-style fg=white,bg=black
      set-option -g status-left "#[fg=green][#[fg=white]#S#[fg=green]]"
      set-option -g status-right "#[fg=green][#[fg=white]%H:%M:%S#[fg=green]]"

      # Window list
      set-option -g window-status-format "#I:#W"
      set-option -g window-status-current-format "#[fg=white]#I:#W"

      # Bind keys for window navigation
      bind-key -n M-Left previous-window
      bind-key -n M-Right next-window

      # Bind keys for copying and pasting
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind-key -T copy-mode-vi Y send-keys -X copy-pipe-and-cancel "xsel -i -b"
      bind-key -T copy-mode-vi p send-keys -X paste-buffer

      # Bind keys for resizing panes
      bind-key -n M-Up resize-pane -U 5
      bind-key -n M-Down resize-pane -D 5
      bind-key -n M-Left resize-pane -L 5
      bind-key -n M-Right resize-pane -R 5

      # Bind keys for focusing panes
      bind-key -n M-Tab select-pane -t :.+
      bind-key -n M-h select-pane -L
      bind-key -n M-l select-pane -R
      bind-key -n M-k select-pane -U
      bind-key -n M-j select-pane -D

      # Bind keys for logging
      bind-key R new-window -n "root" "sudo su -"
      bind-key L new-window -n "syslog" "journalctl -fn -l -q"
      bind-key D new-window -n "docker-stats" "docker-ps"
      bind-key P new-window -n "top" "${pkgs.btop}/bin/btop --low-color"

      # Create initial windows
      new-window -n "flake" "$SHELL"
      new-window -n "syslog" "journalctl -fn -l -q"
      new-window -n "top" "btop --low-color"
      new-window -n "src" "$SHELL"
      new-window -n "misc" "$SHELL"

      # Select the first window
      select-window -t 0
    '';
  };
}
