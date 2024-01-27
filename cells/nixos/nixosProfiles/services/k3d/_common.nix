{ config, lib, pkgs, masterModulesPath, ... }:
with lib;
let
  resolvConf = ''
    nameserver 10.11.1.4
  '';
  macvlan = "lan";
in
{
  # systemd.services.k3s-dkr-net = {
  #   path = with pkgs; [ jq docker ];
  #   before = [ "docker-k3s.service" ];
  #   after = [ "zerotierone.service" ];
  #   wantedBy = [ "docker-k3s.service" ];
  #   script = ''
  #     _create_docker_network() {
  #       docker network create -d macvlan \
  #         -o parent=${macvlan} \
  #         --subnet=10.11.1.0/24 \
  #         --gateway=10.11.1.254 \
  #         --ip-range=10.11.1.80-10.11.1.90 \
  #         k3s-zt
  #     }
  #     ! docker network ls --format '{{json .}}' | jq -e --arg admin_net pdns-admin 'select(.Name == $admin_net and .Driver =="macvlan") | any' | grep -q true && _create_docker_network || true
  #   '';
  # };

  virtualisation.oci-containers.containers.k3s = {
    autoStart = true;
    image = "rancher/k3s";
    imageFile = pkgs.dockerTools.pullImage {
      imageName = "rancher/k3s";
      imageDigest = "sha256:24b7551320a241cfcdc0403436bc8bcc96b2d349084c1caf71f226a08784c417";
      sha256 = "0sw2g68kfqnmbxapjjs9ahzahsga4ca1k3zydd40b9gpzs2zl0yi";
    };

    # environment = { };

    extraOptions = mkBefore [
      # "--tmpfs /run"
      # "--tmpfs /var/run"
      "--privileged"
      "--network=pdns-admin"
    ];

    volumes = [
      "/persist/k3s:/var/lib/rancher/k3s"
      # "${resolvConf}:/etc/resolv.conf"
    ];

    cmd = mkAfter [ "--snapshotter=native" ];
  };

}
