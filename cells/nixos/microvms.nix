{ inputs, cell, ... }:
let
  bee = {
    system = "x86_64-linux";
    home = inputs.home-unstable;
    pkgs = import inputs.nixpkgs-unstable {
      inherit (inputs.nixpkgs) system;
      config.allowUnfree = true;
      overlays = with inputs.cells.common.overlays; [
        sources
        stumpwm
        make-desktopitem
        nixpkgs-unstable-overrides
        nixpkgs-master-overrides
      ];
    };
  };

  sops-experimental = { lib, config, pkgs, ... }: {
    microvm.shares = [
      {
        proto = "9p";
        tag = "ro-ssh_host_keys";
        source = "/tmp/ssh_keys";
        mountPoint = "/etc/ssh_keys";
      }
    ];

    # systemd.sysusers.enable = true;
    # users.mutableUsers = true;
    # system.etc.overlay.enable = true;

    environment.systemPackages = [
      (pkgs.writeScriptBin "sops-setup"
        config.system.activationScripts.setupSecretsForUsers.text)
    ];

    # sops.gnupg.sshKeyPaths = [ "/etc/ssh_keys/ssh_host_ed25519_key" ];
    sops.gnupg.sshKeyPaths = lib.mkForce [ ];
    # sops.age.generateKey = true;
    sops.age.sshKeyPaths = lib.mkForce [ "/etc/ssh_keys/ssh_host_ed25519_key" ];

    services.openssh.hostKeys = lib.mkForce [
      {
        path = "/etc/ssh_keys/ssh_host_rsa_key";
        bits = 4096;
        openSSHFormat = true;
        comment = "Default - ${config.networking.hostName}";
        rounds = 100;
        type = "rsa";

      }

      {
        path = "/etc/ssh_keys/ssh_host_ed25519_key";
        bits = 4096;
        openSSHFormat = true;
        comment = "sops/age/colmena - for ${config.networking.hostName}";
        rounds = 100;
        type = "ed25519";
      }
    ];
  };

  common-config = { config, ... }: {
    imports = cell.nixosSuites.base ++ [
      (import "${inputs.hive}/src/beeModule.nix" { nixpkgs = bee.pkgs; })
      bee.home.nixosModules.default
      inputs.cells.nixos.nixosProfiles.networking.openssh
      inputs.cells.nixos.nixosProfiles.core.kernel.physical-access-system
    ];

    nixpkgs.pkgs = bee.pkgs;

    documentation.enable = false;

    networking.hostId = "23f7e2ff";
    networking.hostName = "marauder";

    services.getty.autologinUser = "admin";

    nix.settings.auto-optimise-store = false;
    nix.optimise.automatic = false;

    microvm.hypervisor = "qemu";
    microvm.vcpu = 4;
    microvm.mem = 4 * 1024;
    microvm.socket = "/tmp/${config.networking.hostName}-microvm.sock";

    microvm.interfaces = [{
      type = "user";
      id = "vm-qemu-1";
      mac = "00:02:00:01:01:00";
    }];

    microvm.forwardPorts = [{
      from = "host";
      host.port = 5999;
      guest.port = 22;
    }];

    # NOTE: home-manager requires a writable store!
    microvm.writableStoreOverlay = "/nix/.rw-store";
    microvm.volumes = [{
      image = "/tmp/nix-store-overlay.img";
      mountPoint = "/nix/.rw-store";
      size = 2048;
    }];

    # NOTE: so, as not to create a qcow image
    microvm.shares = [
      {
        # proto = "virtiofs";
        proto = "9p";
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }
    ];
  };

  desktop-config = { pkgs, ... }: {
    # services.xserver.desktopManager.mate.enable = true;
    imports = [ inputs.cells.nixos.nixosModules.services.x11.window-managers.stumpwm ];
    services.xserver.windowManager.stumpwm.enable = true;
    hardware.opengl.enable = true;
    microvm.graphics.enable = true;
    microvm.qemu.extraArgs = [
      "-vnc"
      ":0"
      "-vga"
      "qxl"

      # needed for mounse/keyboard input via vnc
      "-device"
      "virtio-keyboard"
      "-usb"
      "-device"
      "usb-tablet,bus=usb-bus.0"
    ];

    microvm.forwardPorts = [{
      from = "host";
      host.port = 5900;
      guest.port = 5900;
    }];

    services.xserver = {
      enable = true;
      # desktopManager.xfce.enable = true;
      displayManager.autoLogin.user = "admin";
    };

    environment.systemPackages = with pkgs; [
      xdg-utils # Required
    ];
  };

in
{
  # std //nixos/microvms/cli:run
  cli = inputs.std.lib.ops.mkMicrovm {
    inherit bee;
    imports = [
      ({ pkgs, ... }: {
        boot.kernelPackages = pkgs.linuxPackages_xanmod_stable;
        boot.zfs.enableUnstable = true;
        boot.zfs.removeLinuxDRM = true;
      })
      common-config
      # sops-experimental
    ];
  };

  # std //nixos/microvms/desktop:run
  desktop = inputs.std.lib.ops.mkMicrovm {
    inherit bee;
    imports =
      inputs.cells.nixos.nixosSuites.desktop ++
      [
        common-config
        desktop-config
        {
          home-manager.users.admin.imports = [
            {
              services.xserver.windowManager.stumpwm.enable = true;
              services.xserver.windowManager.stumpwm.confDir = ../home/userProfiles/vod/dotfiles/stumpwm.d;
            }
          ];
        }

      ];
  };

}
