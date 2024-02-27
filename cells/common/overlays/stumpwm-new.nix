{ inputs, cell, ... }:

final: prev:

let
  # createAsd = { url, sha256, asd, system }:
  #   with prev;
  #   let
  #     src = fetchzip { inherit url sha256; };
  #   in
  #   if asd == system
  #   then src
  #   else
  #     runCommand "source" { } ''
  #       mkdir -pv $out
  #       cp -r ${src}/* $out
  #       find $out -name "${asd}.asd" | while read f; do mv -fv $f $(dirname $f)/${system}.asd || true; done
  #     '';

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
      # Patches are already applied in `build`
      patches = [ ];
      src = build;
    });

  stumpwm_release = (build-asdf-system {
    inherit (final.sources.stumpwm-release) src pname version;
    asds = [ "stumpwm" ];
    systems = [ "stumpwm" ];
    lispLibs = with final.sbcl.pkgs; [
      alexandria
      cl-ppcre
      clx
      stumpwm_release_dynamic-mixins-swm
    ];
  });

  stumpwm_release_bin = stumpwm_release.overrideLispAttrs (o: rec {
    inherit (final.sources.stumpwm-release) src pname version;

    buildScript = prev.writeText "build-stumpwm.lisp" ''
      (load "${stumpwm_release.asdfFasl}/asdf.${stumpwm_release.faslExt}")

      (asdf:load-system 'stumpwm)

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
        :purify t
        #+sb-core-compression :compression
        #+sb-core-compression t
        :toplevel #'stumpwm:stumpwm)
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp -v stumpwm $out/bin
    '';
  });

  stumpwm_release_dynamic-mixins-swm = build-with-compile-into-pwd rec {
    inherit (final.sources.stumpwm-release) version;
    pname = "dynamic-mixins-swm";
    src = "${final.sources.stumpwm-release.src}/dynamic-mixins";
    systems = [ "dynamic-mixins-swm" ];
    asds = systems;
    lispLibs = [ final.sbcl.pkgs.alexandria ];
  };


  stumpwm_release_stumpish = prev.writeShellApplication {
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

  # depends-on = filter (e: (e != "" && e != "stumpwm"))
  #   (splitString ":" (fileContents (prev.runCommandNoCC "findDependencies"
  #     {
  #       buildInputs = with prev; [ gnused findutils coreutils ];
  #     }
  #     ''
  #       asdFile=$(find ${src} -type f -name \*.asd)

  #       sed -n '/:depends-on (/{
  #       :loop
  #       $!{N;b loop}
  #       s/.*:depends-on (\([^)]*\)).*/\1/p
  #       }' $asdFile | tr -d ' \n#' > $out
  #     '')));

  stumpwm-contrib-build-system = src:
    with (inputs.nixpkgs-lib.lib // builtins);
    let
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
            lispLibs ${src} $out
          '')));
      lispLibs =
        let
          inherit (prev.lib)
            optional
            elem
            attrValues
            filterAttrs
            hasPrefix
            optionalAttrs;
        in
        [ stumpwm_release ] ++
        (optional
          (depends-on != [ ])
          (map (e: final.sbcl.pkgs.${e} or final.stumpwm-contrib.${e}) depends-on)) ++
        (optional
          (elem "mcclim" depends-on)
          (attrValues (filterAttrs (n: v: hasPrefix "mcclim" n) final.sbcl.pkgs)));
      pname = baseNameOf src;
      inherit (final.sources.stumpwm-contrib) version;
    in
    # { inherit getDepsScript depends-on lispLibs pname src; fdrv = build-with-compile-into-pwd { inherit src lispLibs pname version; }; };
    build-with-compile-into-pwd { inherit src lispLibs pname version; } //
    (optionalAttrs (pname == "golden-ratio") { systems = [ "swm-golden-ratio" ]; });

  sbcl = prev.sbcl.withOverrides (finalLisp: prevLisp: rec {

    "(FEATURE LINUX cl-mount-info)" = cl-mount-info;

    cl-mount-info = build-with-compile-into-pwd {
      inherit (final.sources.cl-mount-info) src pname version;
      lispLibs = with final.sbcl.pkgs; [
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

  stumpwm-contrib =
    with builtins;
    with final.lib; let
      broken = [
        "golden-ratio" # FIXME: lisp script cannot find the system, since the name is swm-golden-ratio
        "pomodoro" # FIXME: as above, swm-pomodoro is the system name

        "swm-clim-message" # default-icons-tmpAAURSO1.fasl
        "clim-mode-line" # default-icons-tmpAAURSO1.fasl
        "debian" # NOTE: because this is not a debian system

        /* BUG:
          ; There is no applicable method for the generic function
          ; #<STANDARD-GENERIC-FUNCTION STUMPWM::SCREEN-CURRENT-GROUP (1)>
          ; when called with arguments
        */
        "kbd-layouts"
        "stump-backlight"
        "lookup"

        "passwd" # NOTE: some lisp bugs
        "qubes" # NOTE: because this is not qubes
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
      buildDirs = [ "media" "minor-mode" "modeline" "util" ];
      allPkgs = fold (p: n: p // n) { } (
        map
          (d:
            let
              srcTop = final.sources.stumpwm-contrib;
              dir = readDir "${srcTop.src}/${d}";
            in
            mapAttrs'
              (k: _: nameValuePair
                k
                (stumpwm-contrib-build-system "${srcTop.src}/${d}/${k}"))
              dir)
          buildDirs
      );
    in
    filterAttrs (k: _: ! elem k broken) allPkgs;

  # sbcl = prev.sbcl.withPackages (pkgs:
  #   with pkgs; [
  #     cl-diskspace
  #     cl-mount-info
  #     xml-emitter
  #     xkeyboard
  #     usocket-server
  #     percent-encoding

  #     clim
  #     # slim
  #     cl-dejavu
  #     opticl
  #     cl-pdf
  #     py-configparser
  #     dexador
  #     str
  #     quri
  #     drakma
  #     yason
  #     alexandria
  #     closer-mop
  #     cl-ppcre
  #     cl-ppcre-unicode
  #     clx
  #     clx-truetype
  #     anaphora
  #     xembed
  #     dbus
  #     bordeaux-threads
  #     cl-strings
  #     cl-hash-util
  #     cl-shellwords
  #     listopia
  #     lparallel
  #     acl-compat
  #     cl-syslog
  #     log4cl
  #   ]);

  slynk = build-with-compile-into-pwd rec {
    inherit (final.emacsPackages.sly) version src;
    pname = "slynk";
    # postUnpack = "src=$src/slynk";
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

  # quicklisp = build-with-compile-into-pwd rec {
  #   pname = "quicklisp";
  #   dontUnpack = true;
  #   # lispLibs = [ slynk ];
  #   inherit (final.sources.quicklisp) src version;
  # };

  slynk-quicklisp = prev.lispPackages_new.build-asdf-system {
    lisp = "${final.sbcl}/bin/sbcl --load ${final.sources.quicklisp.src} --eval '(quicklisp-quickstart:install)' --script";
    preConfigure = ''export HOME=$(mktemp -d)'';
    __impure = true;
    pname = "slynk-quicklisp";
    lispLibs = [ slynk ];
    inherit (final.emacsPackages.sly-quicklisp) src version;
  };

  slynk-asdf = build-with-compile-into-pwd rec {
    pname = "slynk-asdf";
    lispLibs = [ slynk ];
    inherit (final.emacsPackages.sly-asdf) src version;
  };

  slynk-named-readtables = build-with-compile-into-pwd rec {
    pname = "slynk-named-readtables";
    lispLibs = [ slynk ];
    inherit (final.emacsPackages.sly-named-readtables) src version;
  };

  slynk-macrostep = build-with-compile-into-pwd rec {
    pname = "slynk-macrostep";
    lispLibs = [ slynk ];
    inherit (final.emacsPackages.sly-macrostep) src version;
  };

  # stumpwm-git-new = nixpkgs-22-11.lispPackages_new.sbclWithPackages (pkgs:
  #   with pkgs;
  #   (builtins.attrValues final.stumpwm-contrib)
  #   ++ [
  #     stumpwmCustomBuild_new_lispPackages

  #     slynk
  #     slynk-macrostep
  #     slynk-named-readtables
  #     slynk-asdf

  #     cl-diskspace
  #     cl-mount-info
  #     xml-emitter
  #     xkeyboard
  #     usocket-server
  #     percent-encoding

  #     clim
  #     # FIXME slim/mcclim
  #     cl-dejavu
  #     opticl
  #     cl-pdf
  #     py-configparser
  #     dexador
  #     str
  #     quri
  #     drakma
  #     yason
  #     alexandria
  #     closer-mop
  #     cl-ppcre
  #     cl-ppcre-unicode
  #     clx
  #     clx-truetype
  #     anaphora
  #     xembed
  #     dbus
  #     bordeaux-threads
  #     cl-strings
  #     cl-hash-util
  #     cl-shellwords
  #     listopia
  #     acl-compat
  #     cl-syslog
  #     log4cl
  #     dbus
  #   ]);

in
{
  inherit
    stumpwm_release
    stumpwm_release_bin
    stumpwm_release_stumpish
    stumpwm_release_dynamic-mixins-swm

    stumpwm-contrib-build-system
    stumpwm-contrib
    sbcl;
}
