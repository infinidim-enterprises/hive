{ inputs, cell, ... }:

{ config, lib, ... }:
with lib;
let ip = head (splitString "/" config.deploy.params.lan.ipv4); in
{

  imports = [ ./_common.nix ];

  services.k3s.role = "agent";
  services.k3s.token = "K10e1b2f49a030e17b6f569cc2afccbaf2041500a0b7f95dc7381344239093f9a53::server:b9c56c21175eb16b37132ce7f427bf41";
  services.k3s.serverAddr = "https://10.12.0.254:6443";
  # services.k3s.tokenFile = "/tmp/.tokenfile";

  services.k3s.extraFlags = concatStringsSep " " [
    "--kubelet-arg cgroup-driver=systemd"
    "--snapshotter=native" # fuse-overlayfs
    # "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
    "--flannel-iface admin-znsd"
    #"--node-label node-role.kubernetes.io/worker=true"

    #     --node-taint key1=value1:NoExecute

    # "--node-ip ${ip}"
    # "--node-external-ip ${ip}"
  ];

}
