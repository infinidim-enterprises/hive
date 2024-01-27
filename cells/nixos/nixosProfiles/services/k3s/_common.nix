{ config, lib, pkgs, masterModulesPath, ... }:
with lib;
{
  disabledModules = [ "services/cluster/k3s/default.nix" ];
  imports = [ "${masterModulesPath}/services/cluster/k3s" ];

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

  networking.firewall.allowedTCPPorts = [ 6443 10250 2379 2380 443 4443 ];
  networking.firewall.allowedUDPPorts = [ 8472 ];
  networking.firewall.extraCommands = ''
    iptables -A INPUT -i cni+ -j ACCEPT
  '';

  virtualisation.containerd.enable = true;
  virtualisation.containers.containersConf.cniPlugins = [ pkgs.cni-plugins ];
  virtualisation.containerd.settings = {
    # plugins.cri.cni = {
    #   bin_dir = "/opt/cni/bin/";
    # };
  };

  systemd.services.containerd.serviceConfig = {
    ExecStartPre = "-${pkgs.zfs}/bin/zfs create -o mountpoint=/var/lib/containerd/io.containerd.snapshotter.v1.zfs rpool/local/containerd";
  };

  services.zerotierone.joinNetworks = [{ "d3b09dd7f50e3236" = "admin-znsd"; }];

  systemd.services.k3s.path = with pkgs; [ systemd jq libressl.nc ];
  systemd.services.k3s.after = [ "network-online.service" ];
  # systemd.services.k3s.serviceConfig.KillMode = mkForce "control-group";
  systemd.services.k3s.preStart =
    let
      jqSel = ''.Interfaces[] | select(.Name | test("admin-znsd")) | .AddressState == "routable"'';
    in
    ''
      until networkctl --json=short | jq '${jqSel}';do echo "Sleeping for 5 until NIC is routable" && sleep 5;done
    '';

  services.k3s.enable = true;
  services.k3s.docker = false;

  # tokenFile = /home/user/.tokenfile;
  # services.k3s.extraFlags = concatStringsSep " " [
  #   "--kubelet-arg cgroup-driver=systemd"
  #   "--snapshotter=native" # fuse-overlayfs
  #   "--container-runtime-endpoint unix:///run/containerd/containerd.sock"

  #   # "--advertise-address 10.11.1.254"

  #   # --cluster-cidr
  # "--resolv-conf value"
  #   # "--flannel-backend=none"
  #   # "--disable-network-policy"

  #   # "--node-ip ${cfg.ip} --node-external-ip ${cfg.ip} --flannel-iface tailscale0"

  #   # "--debug"
  #   # "--disable coredns,servicelb,traefik,local-storage,metrics-server"
  # ];

}
