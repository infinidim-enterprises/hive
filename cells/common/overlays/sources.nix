{ inputs, cell, ... }:

final: prev:
{
  sources =
    (final.callPackage ../sources/misc/generated.nix { }) //
    (final.callPackage ../sources/shell/generated.nix { });
}
