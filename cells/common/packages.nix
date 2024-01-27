{ inputs, cell, ... }:
cell.lib.importers.importPackagesRakeleaves {
  src = ./packages;
  overlays = [ cell.overlays.sources ];
  skip = [
    "TakeTheTime"
    "age-plugin-yubikey"
    "activitywatch"
    "promnesia"
    "HPI"
    "aw-client"
    "aw-core"
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
