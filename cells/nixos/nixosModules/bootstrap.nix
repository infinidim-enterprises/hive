{ config, lib, pkgs, self, ... }:
let
  inherit (lib)
    mkIf
    mkMerge
    flatten
    attrNames
    hasSuffix
    filterAttrs
    hasAttrByPath
    mapAttrsToList
    concatStringsSep;

  inherit (builtins)
    map
    getFlake
    toString
    attrValues;

  hosts_with_disko = filterAttrs
    (n: v:
      hasSuffix "bootstrap" n &&
      hasAttrByPath [ "disko" ] v.config)
    self.nixosConfigurations;

  installable_hosts = mapAttrsToList (_: host: host.config.system.build.toplevel) hosts_with_disko;

  diskoDisks = cfg:
    let
      deviceList = mapAttrsToList
        (k: v: "--disk ${k} \"${v.device}\"")
        cfg.disko.devices.disk;
    in
    concatStringsSep " " deviceList;

  installScriptUnattended = host:
    pkgs.writeShellScriptBin "install-${host}" ''
      set -eux
      exec ${pkgs.disko}/bin/disko-install \
        --option extra-experimental-features auto-allocate-uids \
        --option extra-experimental-features cgroups \
        --flake "${self}#${host}" ${diskoDisks self.nixosConfigurations.${host}.config}
    '';

  diskoScript = host:
    pkgs.writeShellScriptBin "disko-${host}" "${self.nixosConfigurations.${host}.config.system.build.diskoScript}";

  diskoScriptPkgs = mapAttrsToList (host: _: [ (installScriptUnattended host) (diskoScript host) ]) hosts_with_disko;

in

{ environment.systemPackages = flatten diskoScriptPkgs; }
