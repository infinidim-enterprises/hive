{ inputs, cell, ... }:

# inputs.cells.common.lib.importers.importProfiles {
#   src = ./homeProfiles;
#   inputs = { inherit cell inputs; };
# }

inputs.cells.common.lib.importers.importProfilesRakeleaves {
  src = ./homeProfiles;
  inputs = { inherit cell inputs; };
}
