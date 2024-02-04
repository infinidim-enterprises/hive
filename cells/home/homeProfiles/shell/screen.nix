{ name, pkgs, lib, ... }:

{
  # TODO: create dvtm/abduco config, instead of screen
  home.packages = [ pkgs.screen ];
  home.file.".screenrc".text = ''
    # -*- conf-space -*-

    # if the following line is present, ~/.profile will not be sourced
    # shell ${pkgs.zsh}/bin/zsh -l
    deflogin on
    bufferfile $HOME/.cache/screen-exchange
    startup_message off
    defscrollback 4096
    autodetach on

    # otherwise it gets set to screen.xterm-256color
    term xterm-256color

    # emulate .logout message
    pow_detach_msg "Screen session of \$LOGNAME \$:cr:\$:nl:ended."

    vbell off
    vbell_msg "     *** DING *** ---- *** DING ***     "

    escape ^Oo
    defutf8 on
    hardstatus on
    hardstatus alwayslastline
    hardstatus string "%{= kG}[%{.kW}%S%{.kG}] [%= %{.kG}%-w%{.kW}%n %t%{-}%+w  %=%{..G}]"

    # show/hide hardstatus: ALT-(up/down)
    bindkey "^[[1;3B" eval "hardstatus ignore"
    bindkey "^[[1;3A" eval "hardstatus alwayslastline"

    # Use ALT-(left/right) prev/next window
    bindkey "^[[1;3D" prev
    bindkey "^[[1;3C" next

    # Copy/buffer mode, change keys to be more emacs'ish
    markkeys @=L=H:$=^E:q=^G:^=^A

    # don't care about case when searching in buffer
    ignorecase on

    # Paste xselection into screen (Could be ^y, if not for my xterm settings!)
    bind y exec .!. xsel -nbo
    # ALT-y Slurp xselection into screen buffer:
    bindkey "^[y" exec sh -c "xsel -nbo > $HOME/.cache/screen-exchange && screen -X readbuf"
    # ALT-w Dump screen buffer into xselection:
    bindkey "^[w" eval "writebuf" "exec sh -c 'xsel -b < $HOME/.cache/screen-exchange'"

    # the '\' doesn't work in NixOS, so
    bind q quit

    # EscapeKey+r puts Screen into resize mode. Resize regions using hjkl keys, toggle focus with Tab and arrow keys.
    bind r eval "command -c classresize" # enter resize mode

    # use bnpf keys to resize regions
    bind -c classresize b eval "resize -h -5" "command -c classresize"
    bind -c classresize n eval "resize -v -5" "command -c classresize"
    bind -c classresize p eval "resize -v +5" "command -c classresize"
    bind -c classresize f eval "resize -h +5" "command -c classresize"

    # quickly switch between regions using tab and arrows
    bind -c classresize \t    eval "focus"       "command -c classresize" # Tab Key
    bind -c classresize -k kl eval "focus left"  "command -c classresize" # Arrow Left
    bind -c classresize -k kr eval "focus right" "command -c classresize" # Arrow Right
    bind -c classresize -k ku eval "focus up"    "command -c classresize" # Arrow Up
    bind -c classresize -k kd eval "focus down"  "command -c classresize" # Arrow Down

    # this grows quickly and it is questionable to have it on all the time
    deflog off
    logfile $HOME/Logs/screen_%d-%m-%Y_%0c
    logfile flush 5
    logstamp on
    logstamp after 60

    bind T screen -t -=ttyUSB0@921.6k=- /dev/ttyUSB0 921600
    bind t screen -t -=ttyUSB0@115.2k=- /dev/ttyUSB0 115200
    bind R screen -t -=root=- 0 sudo su -
    bind L screen -t -=syslog=- 1 journalctl -fn -l -q
    bind D screen -t docker-stats 5 $SHELL -c docker-ps
    bind P screen -t -=top=- 2 ${pkgs.btop}/bin/btop

    # chdir $HOME/Projects/world
    screen -t -=flake=- 0 $SHELL
    screen -t -=syslog=- 1 journalctl -fn -l -q
    chdir $HOME
    screen -t -=top=- 2 ${pkgs.btop}/bin/btop
    screen -t src 2 $SHELL
    screen -t misc 3 $SHELL
    select 0
  '';
}
