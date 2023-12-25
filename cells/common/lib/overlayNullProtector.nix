{ lib, ... }:
let
  overlayNullProtector = {
    __functor = _self: overlay: final: prev:
      if prev == null || (prev.isFakePkgs or false)
      then { }
      else overlay final prev;

    doc = ''
      [WORKAROUND] https://github.com/divnix/digga/issues/464

      Latest changes in emacs-overlay caused digga to stop working.
      Has to do with exporting overlays.
    '';
  };
in
overlayNullProtector
