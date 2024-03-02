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

  stumpwm-contrib-build-system = src:
    let
      broken_asd_names = [ "golden-ratio" "pomodoro" ];
      fix_dirname = prev.runCommandNoCC "fix_broken_dirname_stumpwm-contrib" { } ''
        mkdir -p $out/swm-${baseNameOf src}
        cp -r ${src}/* $out/swm-${baseNameOf src}
      '';
      src' =
        if elem (baseNameOf src) broken_asd_names
        then "${fix_dirname}/swm-${baseNameOf src}"
        else src;
      getDepsScript = prev.writeScriptBin "lispLibs"
        ("#!${prev.sbcl}/bin/sbcl --script\n" +
          (fileContents ./find-lisp-deps.lisp));
      depends-on = filter
        (e: (e != "" &&
          e != "stumpwm" &&
          e != "uiop"))
        (splitString "," (fileContents (prev.runCommandNoCC "findDependencies"
          { buildInputs = [ getDepsScript ]; }
          ''
            lispLibs ${src'} $out
          '')));
      lispLibs = [ unwrapped ] ++
        (optional
          (depends-on != [ ])
          (map (e: final.stumpwm_release_latest.sbcl.pkgs.${e} or final.stumpwm_release_latest.stumpwm-contrib.${e}) depends-on)) ++
        (optional
          (elem "mcclim" depends-on)
          (attrValues (filterAttrs (n: v: hasPrefix "mcclim" n) final.stumpwm_release_latest.sbcl.pkgs)));
      pname = baseNameOf src';
      inherit (final.sources.stumpwm-contrib) version;
    in
    build-with-compile-into-pwd { inherit lispLibs pname version; src = src'; };

  unwrapped = (build-asdf-system {
    inherit (final.sources.stumpwm-release) src pname version;
    asds = [ "stumpwm" ];
    systems = [ "stumpwm" ];
    lispLibs = with final.stumpwm_release_latest.sbcl.pkgs; [
      ### Minimum required
      alexandria
      cl-ppcre
      clx
      dynamic-mixins

      ### Additional pkgs
      cl-diskspace
      cl-mount-info
      cl-strings
      cl-hash-util
      cl-shellwords
      cl-dejavu
      cl-pdf
      cl-ppcre-unicode
      cl-syslog
      clx-truetype
      log4cl
      xml-emitter
      xkeyboard
      usocket-server
      percent-encoding
      clim
      opticl
      py-configparser
      dexador
      str
      quri
      drakma
      yason
      alexandria
      closer-mop
      anaphora
      xembed
      dbus
      bordeaux-threads
      listopia
      lparallel
      acl-compat

      ### Sly stuff
      slynk
      # FIXME: slynk-quicklisp
      slynk-asdf
      slynk-named-readtables
      slynk-macrostep
    ];
  });

  bin = unwrapped.overrideLispAttrs (o: rec {
    inherit (final.sources.stumpwm-release) src pname version;

    buildScript = prev.writeText "build-stumpwm.lisp" ''
      (load "${sbcl_with_pkgs.asdfFasl}/asdf.${sbcl_with_pkgs.faslExt}")
      (declaim #+sbcl(sb-ext:muffle-conditions style-warning))
      (asdf:load-system 'stumpwm)

      (defun stumpwm::data-dir () (merge-pathnames "Logs/" (user-homedir-pathname)))

      ;; Prevents package conflict error
      (when (uiop:version<= "3.1.5" (asdf:asdf-version))
        (uiop:symbol-call '#:asdf '#:register-immutable-system :stumpwm)
        (dolist (system-name (uiop:symbol-call '#:asdf
                                               '#:system-depends-on
                                               (asdf:find-system :stumpwm)))
          (uiop:symbol-call '#:asdf '#:register-immutable-system system-name)))

      ;; Prevents "cannot create /homeless-shelter" error
      (asdf:disable-output-translations)

      (sb-ext:save-lisp-and-die
        "stumpwm"
        :executable t
        :save-runtime-options t
        :purify t
        #+sb-core-compression :compression
        #+sb-core-compression t
        :toplevel #'stumpwm:stumpwm)
    '';
    /*
          --eval '(declaim #+sbcl(sb-ext:muffle-conditions style-warning))' \
          --eval '(require :asdf)' \
          --eval '(require :stumpwm)' \
      XDG_LOGS_DIR
          --eval '(defun stumpwm::data-dir () (merge-pathnames "Logs/" (user-homedir-pathname)))' \
          --eval '(stumpwm:stumpwm)' \
          --eval '(quit)'

    */
    installPhase = ''
      mkdir -p $out/bin
      cp -v stumpwm $out/bin
    '';
  });

  dynamic-mixins = build-with-compile-into-pwd rec {
    inherit (final.sources.stumpwm-release) version;
    pname = "dynamic-mixins-swm";
    src = "${final.sources.stumpwm-release.src}/dynamic-mixins";
    systems = [ "dynamic-mixins-swm" ];
    asds = systems;
    lispLibs = [ final.stumpwm_release_latest.sbcl.pkgs.alexandria ];
  };


  stumpish = prev.writeShellApplication {
    name = "stumpish";
    runtimeInputs = with prev; [
      gnused
      xorg.xprop
      rlwrap
      ncurses
    ];

    excludeShellChecks = [
      "SC2162"
      "SC2046"
      "SC2005"
      "SC2268"
      "SC2086"
      "SC2068"
    ];

    text = with builtins;
      (replaceStrings
        [ "#!/bin/sh" ]
        [ "" ]
        (readFile "${final.sources.stumpwm-contrib.src}/util/stumpish/stumpish"));
  };

  sbcl = prev.sbcl.withOverrides (finalLisp: prevLisp: rec {

    "(FEATURE LINUX cl-mount-info)" = cl-mount-info;

    cl-mount-info = build-with-compile-into-pwd {
      inherit (final.sources.cl-mount-info) src pname version;
      lispLibs = with final.stumpwm_release_latest.sbcl.pkgs; [
        alexandria
        cffi
        cl-ppcre
      ];
    };

    mcclim-layouts = build-with-compile-into-pwd { inherit (prevLisp.mcclim-layouts) src lispLibs pname version; };
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
    unwrapped
  ] ++ (attrValues stumpwm-contrib));

  stumpwm-contrib =
    let
      broken = [
        "swm-clim-message" # BUG: default-icons-tmpAAURSO1.fasl
        "clim-mode-line" # BUG: default-icons-tmpAAURSO1.fasl

        "passwd" # NOTE: some lisp bugs

        /* BUG:
          ; There is no applicable method for the generic function
          ; #<STANDARD-GENERIC-FUNCTION STUMPWM::SCREEN-CURRENT-GROUP (1)>
          ; when called with arguments
        */
        "kbd-layouts"
        "stump-backlight"
        "lookup"

        "qubes" # NOTE: because this is not qubes
        "debian" # NOTE: because this is not debian
        "stumpish" # NOTE: stumpish is a shell-script and it's being installed separately

        "screenshot" # BUG: BUILD FAILED: The name "STUMPWM" does not designate any package.

        /* BUG:
          ; caught ERROR:
          ;   (during macroexpansion of (AUTO-DEFINE-SURFRAW-COMMANDS-FROM-ELVIS-LIST))
          ;   The function SURFRAW::SURFRAW-ELVIS-LIST is undefined.
          ;   It is defined earlier in the file but is not available at compile-time.
        */
        "surfraw"
      ];
      srcTop = final.sources.stumpwm-contrib.src;
      allPkgs = fold (p: n: p // n) { } (
        map
          (d: mapAttrs'
            (k: _: nameValuePair
              k
              (stumpwm-contrib-build-system "${srcTop}/${d}/${k}"))
            (readDir "${srcTop}/${d}"))
          [ "media" "minor-mode" "modeline" "util" ]
      );
    in
    filterAttrs (k: _: ! elem k broken) allPkgs;

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

  # slynk-quicklisp = build-with-compile-into-pwd {
  #   lisp = "${final.sbcl}/bin/sbcl --load ${final.sources.quicklisp.src} --eval '(quicklisp-quickstart:install)' --script";
  #   preConfigure = ''export HOME=$(mktemp -d)'';
  #   __impure = true;
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
  stumpwm_release_latest = {
    inherit
      sbcl
      sbcl_with_pkgs

      bin
      stumpish
      unwrapped
      stumpwm-contrib

      slynk
      # slynk-quicklisp
      slynk-asdf
      slynk-named-readtables
      slynk-macrostep;
  };
}
