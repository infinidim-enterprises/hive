{ inputs, cell, ... }:

final: prev:

let
  inherit (inputs.nixpkgs-lib.lib // builtins)
    attrValues
    filterAttrs
    optionalAttrs
    mapAttrs'
    nameValuePair
    fold

    fileContents
    splitString

    optional
    elem
    filter

    hasPrefix
    readDir;

  build-asdf-system = prev.sbcl.buildASDFSystem;

  sbcl_unwrapped = prev.sbcl.override {
    purgeNixReferences = true; # NOTE: produce binaries for non-NixOS
    coreCompression = false; # NOTE: works when purgeNixReferences = false
  };

  sbcl_wrapped = prev.wrapLisp {
    pkg = sbcl_unwrapped;
    faslExt = "fasl";
    flags = [ "--dynamic-space-size" "3000" ];
  };

  sbcl = sbcl_wrapped.withOverrides (finalLisp: prevLisp: rec {

    "(FEATURE LINUX cl-mount-info)" = cl-mount-info;

    cl-mount-info = build-with-compile-into-pwd {
      inherit (final.sources.cl-mount-info) src pname version;
      lispLibs = with final.stumpwm_release_latest.sbcl.pkgs; [
        alexandria
        cffi
        cl-ppcre
      ];
    };

    mcclim-layouts = build-with-compile-into-pwd {
      inherit (prevLisp.mcclim-layouts)
        src
        lispLibs
        pname
        version;
    };
    mcclim-fontconfig = prevLisp.mcclim-fontconfig.overrideLispAttrs (oldAttrs: {
      nativeLibs = with prev; [ pkg-config fontconfig ];
    });
    mcclim-harfbuzz = prevLisp.mcclim-harfbuzz.overrideLispAttrs (oldAttrs: {
      nativeLibs = with prev; [ pkg-config harfbuzz freetype ];
    });
  });

  sbcl_with_pkgs = sbcl.withPackages (p: [
    slynk
    slynk-asdf
    slynk-named-readtables
    slynk-macrostep
  ]);


  build-with-compile-into-pwd = args:
    let
      build = (build-asdf-system (args // { version = args.version + "-build"; })).overrideAttrs (o: {
        buildPhase = with builtins; ''
          mkdir __fasls
          export ASDF_OUTPUT_TRANSLATIONS="$(pwd):$(pwd)/__fasls:${storeDir}:${storeDir}"
          export CL_SOURCE_REGISTRY=$CL_SOURCE_REGISTRY:$(pwd)//
          ${o.pkg}/bin/${o.program} ${toString (o.flags or [])} < ${o.buildScript}
        '';
        installPhase = ''
          mkdir -pv $out
          rm -rf __fasls
          cp -r * $out
        '';
      });
    in
    build-asdf-system (args // {
      patches = [ ];
      src = build;
    });

  slynk = build-with-compile-into-pwd rec {
    inherit (final.emacsPackages.sly) version src;
    pname = "slynk";
    systems = [
      "slynk"
      "slynk/mrepl"
      "slynk/arglists"
      "slynk/package-fu"
      "slynk/stickers"
      "slynk/indentation"
      "slynk/retro"
      "slynk/fancy-inspector"
      "slynk/trace-dialog"
      "slynk/profiler"
    ];
  };

  slynk-quicklisp = build-with-compile-into-pwd {
    lisp = "${final.sbcl}/bin/sbcl --load ${final.sources.quicklisp.src} --eval '(quicklisp-quickstart:install)' --script";
    preConfigure = ''export HOME=$(mktemp -d)'';
    # __impure = true;
    pname = "slynk-quicklisp";
    lispLibs = [ slynk ];
    inherit (final.emacsPackages.sly-quicklisp) src version;
  };

  # slynk-quicklisp = build-with-compile-into-pwd {
  #   pname = "slynk-quicklisp";
  #   lispLibs = [ slynk ];
  #   inherit (final.emacsPackages.sly-quicklisp) src version;
  # };

  slynk-asdf = build-with-compile-into-pwd {
    pname = "slynk-asdf";
    lispLibs = [ slynk ];
    inherit (final.emacsPackages.sly-asdf) src version;
  };

  slynk-named-readtables = build-with-compile-into-pwd {
    pname = "slynk-named-readtables";
    lispLibs = [ slynk ];
    inherit (final.emacsPackages.sly-named-readtables) src version;
  };

  slynk-macrostep = build-with-compile-into-pwd {
    pname = "slynk-macrostep";
    lispLibs = [ slynk ];
    inherit (final.emacsPackages.sly-macrostep) src version;
  };

in
{
  nyxt_with_slynk = {
    inherit
      sbcl
      sbcl_with_pkgs

      slynk
      slynk-quicklisp
      slynk-asdf
      slynk-named-readtables
      slynk-macrostep;
  };
}
