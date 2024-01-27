{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
with lib;
{
  imports = [ ./_common.nix ];
  virtualisation.oci-containers.containers.k3s = {
    cmd = mkBefore [ "server" ];
    environment = {
      # K3S_KUBECONFIG_OUTPUT = "/output/kubeconfig.yaml";
      K3S_KUBECONFIG_MODE = "644";
    };

    extraOptions = mkAfter [
      "--ip=10.11.1.81"
    ];

    # volumes = [ "/persist/k3s/kubeconfig.yaml:/output/kubeconfig.yaml" ];
  };

}
