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
      bind.address = "/run/user/0/gnupg/S.gpg-agent";
      host.address = replaceStrings [ "%t" ] [ "/run/user/${toString uid}" ]
        config.systemd.user.sockets.gpg-agent-extra.Socket.ListenStream;
    }];

  })

  {
    programs.ssh = {
      enable = true;
      compression = true;
      serverAliveInterval = 30;
      extraOptionOverrides.StrictHostKeyChecking = "no";
      extraOptionOverrides.IdentitiesOnly = "no";

      matchBlocks = {
        "eadrax eadrax.njk.*" = defaults_njk // { user = name; };
        "arm64 arm64.njk.*" = defaults_njk // { user = "root"; port = 65522; };
        "git.0a.njk.li" = defaults_njk_gitea;
        "*.0a.njk.li" = defaults_njk;
        "*.0.njk.li" = defaults_njk;
        "damogran damogran.njk.*" = defaults_njk;
        # "nowhat* nowhat*.0*.njk.li".port = 65522;
        # "maintenance* maintenance*.0*.njk.li".port = 65522;
        "kakrafoon kakrafoon.njk.*" = defaults_njk // {
          port = 65522;
          localForwards = [{
            bind.address = "127.0.0.1";
            bind.port = 5432;
            host.address = "127.0.0.1";
            host.port = 5432;
          }];

        };
        "bitbucket.org" = defaults_git;
        "github.com" = defaults_git;
      };
    };
  }
]
