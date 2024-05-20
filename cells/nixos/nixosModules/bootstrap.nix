{ config, lib, pkgs, self, ... }:
let
  inherit (lib)
    mkIf
    mkMerge
    flatten
    attrNames
    hasSuffix
    filterAttrs
    fileContents
    hasAttrByPath
    mapAttrsToList
    concatStringsSep;

  inherit (builtins)
    map
    getFlake
    toString
    attrValues;

  # FIXME: ugly shit, git can have multiple remotes
  flake_uri = pkgs.runCommandNoCC "flake_uri"
    {
      buildInputs = with pkgs; [ gawk gitMinimal ];
    } ''
    cd ${self.outPath}
    export HOME=$TEMPDIR
    git config --global --add safe.directory ${self.outPath}
    cat .git/config | grep url | awk -F '@' '{print $2}' | awk -F '.git' '{print $1}' > $out
  '';

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
        --flake "${fileContents flake_uri}#${host}" ${diskoDisks self.nixosConfigurations.${host}.config}
    '';

  diskoScript = host:
    pkgs.writeShellScriptBin "disko-${host}" "${self.nixosConfigurations.${host}.config.system.build.diskoScript}";

  diskoScriptPkgs = mapAttrsToList (host: _: [ (installScriptUnattended host) (diskoScript host) ]) hosts_with_disko;

in

{ environment.systemPackages = flatten diskoScriptPkgs; }
