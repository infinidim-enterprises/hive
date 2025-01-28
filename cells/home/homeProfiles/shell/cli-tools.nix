{ pkgs, ... }:
let
  iotop_task_delayacct = pkgs.writeShellApplication {
    name = "iotop";
    runtimeInputs = with pkgs; [ procps ];
    text = ''
      # Function to disable task_delayacct upon script exit
      disable_task_delayacct() {
          sudo sysctl kernel.task_delayacct=0 >/dev/null 2>&1
      }

      # Ensure disable_task_delayacct is called on script exit
      trap 'disable_task_delayacct' EXIT

      # Check if the user has sudo capabilities
      if ! sudo -n true 2>/dev/null; then
          echo "Error: This script requires sudo privileges."
          exit 1
      fi

      # Check the value of kernel.task_delayacct
      task_delayacct_value=$(sysctl -n kernel.task_delayacct)

      if [ "$task_delayacct_value" -eq 0 ]; then
          # Set kernel.task_delayacct to 1
          sudo sysctl kernel.task_delayacct=1 >/dev/null 2>&1

          # Run iotop with passed arguments
          sudo ${pkgs.iotop-c}/bin/iotop-c --processes --only "$@"
      else
          # Find the already running iotop process and print its PID and COMMAND
          ps -C 'iotop-c' -o pid,cmd
      fi
    '';
  };

in
{
  programs.bat.enable = true;
  programs.dircolors.enable = true;
  home.packages = with pkgs; [
    tmate #TODO: make a home-manager module - https://tmate.io Instant terminal sharing
    tty-share # Secure terminal-session sharing - https://tty-share.com
    upterm # Secure terminal-session sharing - https://upterm.dev
    eternal-terminal # TODO: Remote shell that automatically reconnects without interrupting the session
    tio # Serial console TTY

    # TODO: shell-gpt - make a home-manager module for this!

    patool # portable archive file manager - https://wummel.github.io/patool
    ouch # easily compressing and decompressing files and directories

    # Process management
    procps # Utilities that give information about processes using the /proc filesystem
    psmisc # A set of small useful utilities that use the proc filesystem (such as fuser, killall and pstree)

    ##
    tree # Command to produce a depth indented directory listing"
    mc # File Manager and User Shell for the GNU Project, known as Midnight Commander
    nnn # File manager
    ncdu # Disk usage analyzer with an ncurses interface
    rsync # Fast incremental file transfer utility
    lsyncd # A utility that synchronizes local directories with remote targets
    # FIXME: magic-wormhole # secure file sharing over cli

    ###
    iotop_task_delayacct # A tool to find out the processes doing the most IO
    iftop # Display bandwidth usage on a network interface
    nload # Monitors network traffic and bandwidth usage with ncurses graphs
    iptraf-ng # A console-based network monitoring utility (fork of iptraf)
    nethogs # A small 'net top' tool, grouping bandwidth by process
    vnstat # Console-based network statistics utility for Linux
    bwm_ng # A small and simple console-based live network and disk io bandwidth monitor
    iperf # Tool to measure IP bandwidth using UDP or TCP
    arping # Broadcasts a who-has ARP packet on the network and prints answers
    ethtool # Utility for controlling network drivers and hardware

    sipcalc # Advanced console ip subnet calculator

    # bottom # A cross-platform graphical process/system monitor with a customizable interface
    btop # top alternative

    jq # command-line JSON processor
    ijq # interactive jq wrapper, requires jq
    oq # A performant, and portable jq wrapper
    pup # jq for html
    fx # Terminal JSON viewer

    python3Packages.pygments # A generic syntax highlighter

    # ix # NOTE: currently defunct! cli pastebin
    ripgrep # A utility that combines the usability of The Silver Searcher with the raw speed of grep
    silver-searcher # NOTE: candidate for dev profile! - modern search
    ack # needed by hhighlighter
    duf # A better df alternative

    curl # A command line tool for transferring files with URL syntax
    wget # Tool for retrieving files using HTTP, HTTPS, and FTP
    httpie # A command line HTTP client whose goal is to make CLI human-friendl
    curlie # Frontend to curl that adds the ease of use of httpie
    http-prompt # Interactive command-line HTTP client featuring autocomplete and syntax highlighting
    httplab # Interactive WebServer
    dogdns # Command-line DNS client
    q # DNS client with support for UDP, TCP, DoT, DoH, DoQ, and ODoH
    gnutls # The GNU Transport Layer Security Library
    surfraw # "Provides a fast unix command line interface to a variety of popular WWW search engines and other artifacts of power"
    w3m # A text-mode web browser
    nb # A command line note-taking, bookmarking, archiving, and knowledge base application
    rclone # Command line program to sync files and directories to and from major cloud storage

    # perl # fzf-history-widget() needs perl to sort input
    # thefuck # if you mistyped: fuck

    # NOTE: Fuck Rust and their liberal fascism religious cult!
    # fselect # Find files with SQL-like queries
    # xsv # CSV processing for CLIs
    # choose # A human-friendly and fast alternative to cut and (sometimes) awk
    # gping # Ping, but with a graph
    # skim # Command-line fuzzy finder written in Rust
    # procs # A modern replacement for ps written in Rust
    # eva # modern bc
    # eza # modern ls (not on LSD)
    # xh # Friendly and fast tool for sending HTTP requests
    # fd # modern find
    # gitui # git tui, the nicer one
    # gping # modern ping
    # hyperfine # benchmark shell commands like a boss
    # manix #  A Fast Documentation Searcher for Nix
    # nix-index # A files database for nixpkgs
    # navi # interactive cli cheat sheet with cheat.sh / tldr integration
    # tealdeer # fast tldr in rust / an (optional) navi runtime dependency
    # procs # modern ps
    # sd # modern sed
    # watchexec # Executes commands in response to file modifications
    # loop # proper loop
    # broot # An interactive tree view, a fuzzy search, a balanced BFS descent and customizable commands

    h # NOTE: candidate for dev # faster shell navigation of projects
    jd-diff-patch # NOTE: candidate for dev # semantic json differ
    pijul # NOTE: candidate for dev profile! # modern darcs-inspired vcs
    git-filter-repo # NOTE: candidate for dev profile! # rewrite git history like a pro (and fast)

    borgbackup # backup tool
  ];
}
