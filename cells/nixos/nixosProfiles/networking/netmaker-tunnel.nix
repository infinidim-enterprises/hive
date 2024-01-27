{ inputs, cell, ... }:

{ self, ... }:

{
  age.secrets."wg-lon" = {
    file = "${self}/secrets/shared/wg-lon.age";
    mode = "0640";
    owner = "root";
    group = "systemd-network";
    path = "/run/secrets/wg-lon.pk";
  };

  systemd.network = {
    netdevs.wg-london.enable = true;
    netdevs.wg-london.netdevConfig.Kind = "wireguard";
    netdevs.wg-london.netdevConfig.Name = "wg-london";

    netdevs.wg-london.wireguardConfig.PrivateKeyFile = "/run/secrets/wg-lon.pk";
    netdevs.wg-london.wireguardPeers = [{
      wireguardPeerConfig = {
        AllowedIPs = [ "10.201.0.0/16" "0.0.0.0/0" ];
        Endpoint = "188.166.149.218:51822";
        PublicKey = "wPsAPU3SYc2k0guI+ut/GvC/O26IdDdRVMaorkR5x0Q=";
        PersistentKeepalive = 20;
      };
    }];

    # NOTE" https://www.freedesktop.org/software/systemd/man/systemd.network.html
    # https://wiki.archlinux.org/title/Mullvad
    # TODO: resolve cache.nixos.org via this dns
    networks.wg-london.networkConfig.DNSSEC = false;
    networks.wg-london.matchConfig.Name = "wg-london";
    networks.wg-london.linkConfig.RequiredForOnline = "no";
    networks.wg-london.addresses = [{ addressConfig.Address = "10.201.0.3/32"; }];
    networks.wg-london.routes = [{
      routeConfig.Gateway = "10.201.0.1";
      routeConfig.GatewayOnLink = "yes";
      routeConfig.Destination = "10.201.0.0/16";
      # routeConfig.Metric = 1024;
    }];
  };

}
