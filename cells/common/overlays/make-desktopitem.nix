{ inputs, cell, ... }:

final: prev: rec {
  make-desktopitem = final.callPackage ../packages/build-support/make-desktopitem { };
  makeDesktopItem = make-desktopitem;
}
