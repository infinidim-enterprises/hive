{ inputs, cell, ... }:
cell.lib.importers.importPackagesRakeleaves {
  src = ./packages;
  overlays = [ cell.overlays.sources ];
  skip = [
    "TakeTheTime"
    "age-plugin-yubikey"

    "promnesia"
    "HPI"
    "timeslot"

    "activitywatch"
    "aw-client"
    "aw-core"
    "persist-queue"

    "chatgpt-wrapper"
    "git-pr-mirror"
    "gitea-tea"
    "huginn"
    "integration-studio"
    "k3d"
    "lita"
    "okteto"
    "roadrunner"

    "zeronsd"
    "git-get"
    "git-remote-ipfs"

    # FIXME:
    "xxhash2mac"
    "uhk-agent"
    "rtw89"
    "kea-ma"
  ];
}

# {
#   misc = cell.lib.importers.importPackages {
#     src = ./packages;
#     overlays = [ cell.overlays.sources ];
#     skip = [
#       "TakeTheTime"
#       "age-plugin-yubikey"
#       "activitywatch"
#       "promnesia"
#       "HPI"
#       "aw-client"
#       "aw-core"
#     ];
#   };
# }
