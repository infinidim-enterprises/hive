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

    "iterable-io"
    # TODO: promnesia https://github.com/NixOS/nixpkgs/pull/215228
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
  ];
}
