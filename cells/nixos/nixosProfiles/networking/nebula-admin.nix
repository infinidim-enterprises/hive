{ inputs, cell, ... }:

{ self, config, ... }:
let
  inherit (config.networking) hostName;
in
{
  age.secrets."nebula-${hostName}.key" = {
    file = "${self}/secrets/hosts/${hostName}/nebula.key.age";
    mode = "0400";
    path = "/var/lib/nebula/networks/admin.key";
  };

  age.secrets."nebula-${hostName}.crt" = {
    file = "${self}/secrets/hosts/${hostName}/nebula.crt.age";
    mode = "0400";
    path = "/var/lib/nebula/networks/admin.crt";
  };

  systemd.services."nebula@admin".after = [ "network-online.target" ];

  services.nebula.networks.admin = {
    enable = true;
    ca = "${self}/secrets/nebula/ca.crt";
    cert = "/var/lib/nebula/networks/admin.crt";
    key = "/var/lib/nebula/networks/admin.key";

    staticHostMap = { "10.22.1.1" = [ "0.njk.li:65242" "192.168.8.1:65242" ]; };
    lighthouses = [ "10.22.1.1" ];
    listen.host = "0.0.0.0";
    listen.port = 65242;
    firewall.outbound = [{ port = "any"; proto = "any"; host = "any"; }];
    firewall.inbound = [{ port = "any"; proto = "any"; host = "any"; }];
  };
}
