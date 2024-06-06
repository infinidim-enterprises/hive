{ inputs, cell, ... }:

{ self, pkgs, lib, config, ... }:
let
  env = "TERM=screen CLICOLOR_FORCE=1 COLORTERM=truecolor";
  duf_impermanence = with lib; " -hide-mp " + "'" + (concatStringsSep "," (cell.lib.impermanenceMounts config)) + "'";
  duf = "${env} ${pkgs.duf}/bin/duf " + "-theme ansi -hide binds,special";
in
{

  environment.interactiveShellInit = ''
    which_nix() {
      realpath $(which $1)
    }
  '';

  environment.variables = {
    # Use custom `less` colors for `man` pages.
    LESS_TERMCAP_md = "$(tput bold 2> /dev/null; tput setaf 2 2> /dev/null)";
    LESS_TERMCAP_me = "$(tput sgr0 2> /dev/null)";

    # Don't clear the screen after quitting a `man` page.
    MANPAGER = "less -X";
  };

  environment.shellAliases =
    {
      df =
        if (cell.lib.isImpermanence config)
        then (duf + duf_impermanence)
        else duf;
      # which = "which_nix";

      # quick cd
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";

      # grep
      grep = "rg";

      # internet ip
      myip = "dig +short myip.opendns.com @208.67.222.222 2>&1";

      sr = "surfraw";
      _ = "sudo";
      cp = "rsync -avh --progress";
      mv = "mv -iv";
      md = "mkdir -pv";
      mkdir = "mkdir -pv";

      docker-ps = "docker ps --format \"table {{.Names}}\t{{.RunningFor}}\t{{.Image}}\"";
      docker-stats = "docker ps --format \"{{ .Names }}\" | xargs docker stats";
      du = "du -sh";

      ec = "emacsclient -c";
      gzip = "pigz";
      history = "fc -El 1";
      ls = "ls -gh --group-directories-first -p -X --color";
      free = "free -h";
      mn = ''
        manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | sk --preview="manix '{}'" | xargs manix
      '';

      # fix nixos-option
      # FIXME: nixos-option = "nixos-option -I nixpkgs=${self}/lib/compat";
      nix-cleanup = "nix-collect-garbage -d && sudo nix-collect-garbage -d";

      # top
      top = "${pkgs.btop}/bin/btop --low-color";
    };
}
