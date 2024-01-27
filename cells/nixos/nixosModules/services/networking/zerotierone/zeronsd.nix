{ config, lib, pkgs, ... }:
with lib;

let
  top = config.services.zerotierone;
  domainOptions = with types; { ... }: {
    options = {
      apiEndpoint = mkOption { type = str; };
      extraHosts = mkOption { type = str; };
      secret = mkOptino { type = str; };
      wildcard = mkEnableOption "*.<zt-id>.domain";
    };
  };
in

{
  options.services.zerotierone.zeronsd = with types; {
    enable = mkEnableOption "Zerotierone nameserver";
    package = mkOption { type = package; default = pkgs.zeronsd; };
    domains = mkOption {
      default = { };
      type = attrsOf (submodule [ domainOptions ]);
    };
  };

  config = mkMerge [
    (mkIf cfg.enable { })
  ];

  # ZEROTIER_CENTRAL_INSTANCE
}
