{ inputs, cell, ... }:

{ pkgs, ... }:
{
  home.packages = with pkgs; [
    curlie # modern curl
    dogdns # modern dig
    duf # modern df
    ripgrep # modern grep
    silver-searcher # NOTE: candidate for dev profile! - modern search
    # eza # rust tool, so fuck it! modern ls (not on LSD)
    fx # Terminal JSON viewer
    # fd # rust tool, so fuck it! modern find
    # gitui # git tui, the nicer one
    # gping # rust tool, so fuck it! modern ping
    # hyperfine # rust tool, so fuck it! benchmark shell commands like a boss
    ijq # interactive jq wrapper, requires jq
    magic-wormhole # secure file sharing over cli
    # navi # interactive cli cheat sheet with cheat.sh / tldr integration
    # NB: nixpkgs#tldr doesn't support the --makdown flag and wouldn't work with navi
    # tealdeer # fast tldr in rust - an (optional) navi runtime dependency
    # procs # modern ps

    # MAYBE: sd # modern sed
    thefuck # if you mistyped: fuck
    tty-share # Secure terminal-session sharing
    # watchexec # Executes commands in response to file modifications
    h # faster shell navigation of projects
    jd-diff-patch # semantic json differ
    arping
    pijul # NOTE: candidate for dev profile! # modern darcs-inspired vcs
    # eva # rust tool, so fuck it! - modern bc
    # manix # rust tool, so fuck it! explore nixos/hm options
    borgbackup # backup tool
    git-filter-repo # NOTE: candidate for dev profile! # rewrite git history like a pro (and fast)
  ];
}
