{ lib ? import <nixpkgs/lib>, networkJson, iaid }:
with (lib // builtins);
let
  network = fromJSON (readFile networkJson);
  isDHCP = (length network.assignedAddresses) < 1;
  isDNS = (length network.dns.servers) > 0;
  isSearchDomain = network.dns.domain != "";
  isAddress = (length network.assignedAddresses) > 0;
  routes = filter (r: r.via != null) network.routes;

  template = ''
    #${network.id}
    [Match]
    Name=${network.portDeviceName}

    [Link]
    ARP=true
    RequiredForOnline=no

    [Network]
    Description=${network.id} [ ${network.name} ]
    # ConfigureWithoutCarrier=true
    IPv6AcceptRA=no
    LinkLocalAddressing=no
    ${optionalString (! isDHCP) "KeepConfiguration=static"}
    DNSSEC=false
    ${if isDHCP then "DHCP=yes" else "DHCP=no"}
  ''
  + optionalString isDNS (concatMapStrings
    (d: ''
      DNS=${d}%${network.portDeviceName}
    '')
    network.dns.servers)

  + optionalString isSearchDomain ''
    Domains=~${network.dns.domain}
  ''

  + optionalString isAddress (concatMapStrings
    (a: ''

      [Address]
      Address=${a}
    '')
    network.assignedAddresses)

  # FIXME: UseRoutes=false
  + optionalString isDHCP ''

    [DHCPv4]
    Anonymize=false
    ClientIdentifier=duid
    DUIDType=uuid
    # IAID=${iaid}
    SendHostname=true
    SendRelease=true
    UseDNS=true
    UseHostname=false
    UseMTU=true
    UseNTP=true
    UseRoutes=false
    UseSIP=true
    UseTimezone=true
  ''
  + optionalString ((length routes) > 0) (concatMapStrings
    (r: ''

      [Route]
      Destination=${r.target}
      Gateway=${r.via}
      GatewayOnLink=yes
      Metric=${toString r.metric}
    '')
    routes);

in
template
