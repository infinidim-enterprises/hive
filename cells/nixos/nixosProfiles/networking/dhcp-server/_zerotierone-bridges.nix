{
  services.kea.vpn-bridges.zerotierone.install =
    let
      duke = "10.100.0";
    in
    {
      subnet4 = [{
        subnet = "${duke}.0/24";
        pools = [{ pool = "${duke}.101 - ${duke}.150"; }];
        option-data = [
          { name = "domain-name"; data = "install.njk.li"; }
          { name = "routers"; data = "${duke}.254"; }
        ];
      }];
      IPMasquerade = "ipv4";
      joinNetworks = [{ "d3b09dd7f53d1214" = "kea-inst"; }];
    };

  services.kea.vpn-bridges.zerotierone.admin-kea =
    let
      duke = "10.22.0";
    in
    {
      subnet4 = [{
        subnet = "${duke}.0/24";
        pools = [{ pool = "${duke}.101 - ${duke}.150"; }];
        option-data = [
          { name = "domain-name"; data = "admin.njk.li"; }
          { name = "routers"; data = "${duke}.254"; }
        ];
      }];
      IPMasquerade = "ipv4";
      joinNetworks = [{ "d3b09dd7f51f90df" = "kea-admin"; }];
    };
}
