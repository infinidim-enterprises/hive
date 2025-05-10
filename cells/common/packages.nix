{ inputs, cell, ... }:

cell.lib.importers.importPackagesRakeleaves
{
  src = ./packages;
  overlays = [ cell.overlays.sources ];
  skip = [
    "pbkdf2-sha512"
    "waveterm"

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

    "shellspec"

    "zeronsd"
    "ztncui"
    "git-get"
    "git-remote-ipfs"

    "trezor-agent-recover"
    "xxhash2mac"
    "uhk-agent"
    "rtw89"
    "kea-ma"
    "make-desktopitem"
    # FIXME: ipxe
    "ipxe"
  ];
}
