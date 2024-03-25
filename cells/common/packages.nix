{ inputs, cell, ... }:
let
  nixpkgs-pycrypto-pinned = import inputs.nixpkgs-pycrypto-pinned {
    inherit (inputs.nixpkgs) system;
    overlays = [ cell.overlays.sources ];
    config.allowUnfree = true;
  };
in

cell.lib.importers.importPackagesRakeleaves
  {
    src = ./packages;
    overlays = [ cell.overlays.sources ];
    skip = [
      "TakeTheTime"
      "age-plugin-yubikey"

      "promnesia"
      "HPI"
      "orgparse"
      "timeslot"

      "activitywatch"
      "aw-client"
      "aw-core"
      "persist-queue"

      "chatgpt-wrapper"
      "langchain"

      "git-pr-mirror"
      "gitea-tea"

      "huginn"
      "integration-studio"
      "k3d"
      "lita"
      "okteto"
      "roadrunner"

      "zeronsd"
      "ztncui"
      "git-get"
      "git-remote-ipfs"

      "trezor-agent-recover"
      # FIXME:
      "xxhash2mac"
      "uhk-agent"
      "rtw89"
      "kea-ma"
      # FIXME: ASAP
      "make-desktopitem"
      # FIXME: ipxe
      "ipxe"
      ### NOTE: gpg-hd must remain pinned to a specific version of pycrypto
      "gpg-hd"
    ];
  } // { gpg-hd = nixpkgs-pycrypto-pinned.callPackage ./packages/tools/python/gpg-hd { }; }
