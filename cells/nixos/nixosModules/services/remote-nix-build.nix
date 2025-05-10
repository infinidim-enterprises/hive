{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
with lib;
let
  inherit (config.njk.lib) credentials;
  cfg = config.njk.services.remote-builder;
  build_machine_template = {
    sshUser = "builder";
    sshKey = "/etc/ssh/ssh_buildfarm";
    maxJobs = 1;
    systems = [ "builtin" "x86_64-linux" "i686-linux" "aarch64-linux" ];
    supportedFeatures = [ "perf" "nixos-test" "benchmark" "big-parallel" "kvm" ];
  };

in
{
  # TODO: avahi/mDNS auto-discovery of builder machines
  options.njk.services.remote-builder = with types; {
    host = {
      enable = mkEnableOption "remote builder host";
    };

    client = {
      enable = mkEnableOption "remote builder client";
      machines = mkOption {
        type = nullOr (listOf attrs);
        apply = l: map (h: mergeAttrs build_machine_template h) l;
        default = [{
          hostName = "argabuthon.0a.njk.li"; # traal.0a.njk.li
          speedFactor = 4;
        }];
      };
    };

  };

  config = mkMerge [
    # either one enabled
    (mkIf (cfg.host.enable || cfg.client.enable) {
      nix.autoOptimiseStore = true;
      nix.distributedBuilds = mkDefault true;
      nix.extraOptions = ''
        builders-use-substitutes = true
      '';
    }
    )

    # clients
    (mkIf cfg.client.enable {
      nix.buildMachines = cfg.client.machines;
      nix.maxJobs = mkDefault 0;
      nix.requireSignedBinaryCaches = true;

      services.openssh.knownHosts.argabuthon = {
        hostNames = [ "argabuthon.0a.njk.li" "10.22.0.222" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdQGKtRw2lBNX/WQXTu61n24ULIzA9DSdH4RJdwjdpH";
      };

      nix.binaryCaches = [ "http://argabuthon.0a.njk.li:5000" ];
      nix.trustedBinaryCaches = [ "http://argabuthon.0a.njk.li:5000" ];
      nix.binaryCachePublicKeys = [ (credentials [ "buildfarm" "nix-serve-public-key" ] "...") (credentials [ "buildfarm" "hydra-nix-serve-public-key" ] "...") ];

      environment.etc."ssh/ssh_buildfarm" = {
        mode = mkDefault "0600";
        text = credentials [ "buildfarm" "privateKey" ] "-----BEGIN  ...";
      };
    }
    )

    # hosts
    (mkIf cfg.host.enable {
      # TODO: https://github.com/grahamc/netboot.nix
      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
      nix.trustedUsers = [ "@builder" ];
      nix.systemFeatures = build_machine_template.supportedFeatures;
      users.groups.builder.gid = 65500;
      users.users.builder = {
        uid = 10000;
        shell = pkgs.bash;
        useDefaultShell = false;
        isNormalUser = true;
        extraGroups = [ "builder" ];
        openssh.authorizedKeys.keys = [ (credentials [ "buildfarm" "publicKey" ] "ssh-rsa ...") ];
        hashedPassword = credentials [ "buildfarm" "passwd" ] "$6$S0g...";
      };

      environment.etc.nix-serve-private-key = {
        mode = "0600";
        user = "nix-serve";
        group = "nogroup";
        text = credentials [ "buildfarm" "nix-serve-private-key" ] "...";
      };

      services.nix-serve.enable = true;
      services.nix-serve.secretKeyFile = "/etc/nix-serve-private-key";
    }
    )
  ];
}
