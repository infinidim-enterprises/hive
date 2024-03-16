{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
let
  inherit (lib) any elemAt mkMerge mkIf mkDefault hasAttr splitString;

  zpoolName = elemAt (splitString "/" config.fileSystems."/".device) 0;
  storageDriver = if (cell.lib.isZfs config) then "zfs" else "overlay2";
in

mkMerge [
  (mkIf (cell.lib.isZfs config) {
    systemd.services.docker.preStart = ''
      ! zfs list ${zpoolName}/docker && zfs create ${zpoolName}/docker || true
    '';

    virtualisation.docker.daemon.settings = {
      storage-opts = [ "zfs.fsname=${zpoolName}/docker" ];
      exec-opts = [ "native.cgroupdriver=systemd" ];
    };

  })

  {
    systemd.enableUnifiedCgroupHierarchy = true;
    boot.kernelParams = [ "cgroup_enable=cpuset" "cgroup_memory=1" "cgroup_enable=memory" ];
    boot.kernelModules = [
      "rbd"
      "br_netfilter"
      "ip_conntrack"
      "ip_vs"
      "ip_vs_rr"
      "ip_vs_wrr"
      "ip_vs_sh"
      "overlay"
    ];

    virtualisation.oci-containers.backend = "docker";

    virtualisation.docker.enable = true;
    virtualisation.docker.enableOnBoot = true;
    # REVIEW: virtualisation.docker.rootless.enable = true;
    # virtualisation.docker.rootless.setSocketVariable = true;
    virtualisation.docker.storageDriver = storageDriver;
    virtualisation.docker.autoPrune.enable = mkDefault true;
    virtualisation.docker.autoPrune.dates = mkDefault "daily";

    environment.systemPackages = with pkgs; [
      ctop
      docker-compose
      docker-machine-kvm2
    ];
  }
]
