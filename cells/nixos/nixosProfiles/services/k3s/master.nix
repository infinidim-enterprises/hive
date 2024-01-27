{ inputs, cell, ... }:

{ config, lib, ... }:
with lib;
let ip = head (splitString "/" config.deploy.params.lan.ipv4); in
{
  imports = [ ./_common.nix ];

  services.k3s.role = "server";
  services.k3s.disableAgent = true;

  services.k3s.extraFlags = concatStringsSep " " [
    # --node-ip ${cfg.ip} --node-external-ip ${cfg.ip} --advertise-address ${cfg.ip}
    # "--kubelet-arg cgroup-driver=systemd"
    # "--snapshotter=native" # fuse-overlayfs
    # "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
    "--disable metrics-server,traefik"

    # "--flannel-iface admin-znsd"

    # "--node-ip ${ip}"
    # "--node-external-ip ${ip}"
    # "--advertise-address ${ip}"

    # "--cluster-domain k3s.njk.local"
  ];

}
