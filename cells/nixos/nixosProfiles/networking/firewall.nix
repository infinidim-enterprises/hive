{ inputs, cell, ... }:

{ lib, ... }:
let inherit (lib) mkDefault; in

{
  networking.firewall.enable = mkDefault true;
  # networking.firewall.allowedTCPPorts = [ 8888 8889 ];
  # networking.firewall.allowedUDPPorts = [ 8888 8889 ];
  networking.firewall.allowPing = mkDefault false;
  networking.firewall.logRefusedConnections = mkDefault false;

  # networking.firewall.extraCommands = ''
  #   # iptables -t nat -A PREROUTING -i eno1 -p tcp --dport 443 -j REDIRECT --to-port 8080
  #   # iptables -t nat -A PREROUTING -i eno1 -p tcp --dport 80 -j REDIRECT --to-port 8080
  # '';

  # NOTE: conntrack helper autoloading has been removed from kernel 6.0 and newer
  # networking.firewall.autoLoadConntrackHelpers = mkDefault true;
  # networking.firewall.connectionTrackingModules = mkDefault [
  #   "ftp"
  #   "irc"
  #   "sane"
  #   "sip"
  #   "tftp"
  #   # "amanda"
  #   # "snmp"
  # ];


}
