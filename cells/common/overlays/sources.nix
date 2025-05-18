{ inputs, cell, ... }:

final: prev:
{
  sources =
    # let
    #   src = [
    #     (final.callPackage ../sources/misc/generated.nix { })
    #     (final.callPackage ../sources/shell/generated.nix { })
    #   ];
    # in
    (final.callPackage ../sources/misc/generated.nix { }) //
    (final.callPackage ../sources/shell/generated.nix { }) //
    {
      hyprwm = final.callPackage ../sources/hyprwm/generated.nix { };
    };
}
