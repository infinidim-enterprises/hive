{ pkgs, lib, name, config, osConfig, ... }:
with lib;
let
  defaults = {
    # identityFile = "~/.ssh/id_rsa.pub";
  };
  defaults_git = { user = "git"; } // defaults;
  defaults_njk = { user = "admin"; forwardAgent = true; } // defaults;
  defaults_njk_gitea = { user = "gitea"; } // defaults;
  inherit (osConfig.users.users.${name}) uid;
in
mkMerge [
  # (mkIf config.services.gpg-agent.enable {
  #   services.gpg-agent.sshKeys = [
  #     "E3C4C12EDF24CA20F167CC7EE203A151BB3FD1AE"
  #     "1953CEBFBC2D71B3CA498433F7EFDE2FDC1E69C5"
  #   ];
  # })

  (mkIf (config.services.gpg-agent.enable && config.services.gpg-agent.enableExtraSocket) {
    # NOTE: https://mlohr.com/gpg-agent-forwarding
    # NOTE: will break if UID is different!
    # TODO: Find out where XDG_RUNTIME_DIR is set and take the value from there
    programs.ssh.matchBlocks."eadrax eadrax.njk.*".remoteForwards = [{
      bind.address = "/run/user/${toString uid}/gnupg/S.gpg-agent";
      host.address = replaceStrings [ "%t" ] [ "/run/user/${toString uid}" ]
        config.systemd.user.sockets.gpg-agent-extra.Socket.ListenStream;
    }];

    programs.ssh.matchBlocks."arm64 arm64.njk.*".remoteForwards = [{
      bind.address = "/run/user/${toString uid}/gnupg/S.gpg-agent";
      host.address = replaceStrings [ "%t" ] [ "/run/user/${toString uid}" ]
        config.systemd.user.sockets.gpg-agent-extra.Socket.ListenStream;
    }];

  })

  {
    programs.ssh = {
      enable = true;
      compression = true;
      serverAliveInterval = 15;
      extraOptionOverrides = {
        StrictHostKeyChecking = "no";
        IdentitiesOnly = "no";
      };

      matchBlocks = {
        "eadrax eadrax.njk.*" = defaults_njk // { user = name; };
        "arm64 arm64.njk.*" = defaults_njk // { user = "root"; };
        "git.0a.njk.li" = defaults_njk_gitea;
        "*.0a.njk.li" = defaults_njk;
        "*.0.njk.li" = defaults_njk;
        "nowhat* nowhat*.0*.njk.li".port = 65522;
        "maintenance* maintenance*.0*.njk.li".port = 65522;
        "kakrafoon* kakrafoon*.0*.njk.li".port = 65522;
        "bitbucket.org" = defaults_git;
        "github.com" = defaults_git;
      };
    };
  }
]
