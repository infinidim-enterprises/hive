{ inputs, cell, ... }:

final: prev:

let
  createAsd = { url, sha256, asd, system }:
    with prev;
    let
      src = fetchzip { inherit url sha256; };
    in
    if asd == system
    then src
    else
      runCommand "source" { } ''
        mkdir -pv $out
        cp -r ${src}/* $out
        find $out -name "${asd}.asd" | while read f; do mv -fv $f $(dirname $f)/${system}.asd || true; done
      '';

  build-asdf-system = prev.sbcl.buildASDFSystem;

  # Used by builds that would otherwise attempt to write into storeDir.
  #
  # Will run build two times, keeping all files created during the
  # first run, exept the FASL's. Then using that directory tree as the
  # source of the second run.
  #
  # E.g. cl-unicode creating .txt files during compilation
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
            hasPrefix;
        in
        [ stumpwm_release ] ++
        (optional
          (depends-on != [ ])
          (map (e: final.sbcl.pkgs.${e}) depends-on)) ++
        (optional
          (elem "mcclim" depends-on)
          (attrValues (filterAttrs (n: v: hasPrefix "mcclim" n) final.sbcl.pkgs)));
      pname = baseNameOf src;
      inherit (final.sources.stumpwm-contrib) version;
    in
    # { inherit getDepsScript depends-on lispLibs pname src; fdrv = build-with-compile-into-pwd { inherit src lispLibs pname version; }; };
    build-with-compile-into-pwd { inherit src lispLibs pname version; };

  # TODO: build mcclim here, mcclim-fontconfig requires pkg-config {nativeLibs = with prev; [ libfixposix ];}

  stumpwm-contrib =
    # clim-mode-line
    # clipboard-history
    with builtins;
    with final.lib; let
      # FIXME: interdeps and mcclim is broken!
      broken = [
        "swm-clim-message"
        "clim-mode-line"
        "debian"
        "kbd-layouts"
        "logitech-g15-keysyms"
        "lookup"
        "passwd"
        "pomodoro"
        "qubes"
        "screenshot"
        "surfraw"
        "stumpish" # NOTE: stumpish is a shell-script
        "stump-backlight"
        "winner-mode"
      ];
      customDeps = { alert-me.lispLibs = [ final.stumpwm-contrib.notifications ]; };
      customASD = { golden-ratio.systems = [ "swm-golden-ratio" ]; };
      buildDirs = [ "media" "minor-mode" "modeline" "util" ];
      allPkgs = fold (p: n: p // n) { } (
        map
          (d:
            let
              srcTop = final.sources.stumpwm-contrib;
              dir = readDir "${srcTop.src}/${d}";
            in
            mapAttrs'
              (k: _:
                let
                  src = with builtins;
                    filterSource
                      (path: _: (match ".*(\.fasl$)" (toString path)) == null)
                      "${srcTop.src}/${d}/${k}";
                  asdfAttrs = with prev.lib;
                    {
                      inherit (srcTop) version;
                      inherit src;
                      pname = k;
                      lispLibs =
                        [ stumpwmCustomBuild_new_lispPackages ]
                        ++ (optionals (hasAttrByPath [ k ] customDeps) customDeps.${k}.lispLibs);
                    }
                    // (optionalAttrs (hasAttrByPath [ k ] customASD) { inherit (customASD.${k}) systems; });
                in
                nameValuePair k (build-with-compile-into-pwd asdfAttrs))
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


  # stumpwm-sndioctl = (build-asdf-system {
  #   pname = "stumpwm-sndioctl";
  #   version = "20210531-git";
  #   asds = [ "stumpwm-sndioctl" ];
  #   src = (createAsd {
  #     url = "http://beta.quicklisp.org/archive/stumpwm-sndioctl/2021-05-31/stumpwm-sndioctl-20210531-git.tgz";
  #     sha256 = "1q4w4grim7izvw01k95wh7bbaaq0hz2ljjhn47nyd7pzrk9dabpv";
  #     system = "stumpwm-sndioctl";
  #     asd = "stumpwm-sndioctl";
  #   });
  #   systems = [ "stumpwm-sndioctl" ];
  #   lispLibs = [ (getAttr "stumpwm" self) ];
  #   meta = {
  #     hydraPlatforms = [ ];
  #   };
  # });


  # mcclim = build-with-compile-into-pwd rec {
  #   inherit (prev.lispPackages_new.sbclPackages.mcclim) src version pname;
  #   systems = [ "mcclim" "mcclim-fonts" "mcclim-fonts/truetype" ];
  #   asds = systems;
  #   lispLibs = [ ];
  # };

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

  quicklisp = build-with-compile-into-pwd rec {
    pname = "quicklisp";
    dontUnpack = true;
    # lispLibs = [ slynk ];
    inherit (final.sources.quicklisp) src version;
  };

  # slynk-quicklisp = prev.lispPackages_new.build-asdf-system {
  #   lisp = "${sbcl}/bin/sbcl --load ${final.sources.quicklisp.src} --eval '(quicklisp-quickstart:install)' --script";
  #   preConfigure = ''export HOME=$(mktemp -d)'';
  #   __impure = true;
  #   pname = "slynk-quicklisp";
  #   lispLibs = [ slynk ];
  #   inherit (final.emacsPackages.sly-quicklisp) src version;
  # };

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

  # stumpwmCustomBuild_new_lispPackages = nixpkgs-22-11.lispPackages_new.build-asdf-system {
  #   buildInputs = with prev; [ autoconf automake makeWrapper ];
  #   lisp = "${sbcl}/bin/sbcl --script";
  #   systems = [ "stumpwm" ];
  #   asds = [ "stumpwm" ];
  #   lispLibs = [ dynamic-mixins ];
  #   inherit (final.sources.stumpwm-git) src version pname system asd;
  #   nativeLibs = with prev; [ libfixposix ];
  # };

  # stumpish = stdenv.mkDerivation rec {
  #   inherit (final.sources.stumpwm-contrib) pname version src;

  #   buildInputs = with prev; [
  #     gnused
  #     xorg.xprop
  #     rlwrap
  #     ncurses
  #   ];

  #   stumpish_bin = (replaceStrings
  #     [ "/bin/sh" ]
  #     [ "${prev.bash}/bin/sh" ]
  #     (readFile "${src}/util/stumpish/stumpish"));

  #   buildPhase = ''
  #     mkdir -p $out/bin
  #   '';

  #   installPhase = ''
  #     cp util/stumpish/stumpish $out/bin
  #   '';
  # };


in
{
  inherit
    stumpwm_release
    stumpwm_release_bin
    stumpwm_release_stumpish
    stumpwm_release_dynamic-mixins-swm

    stumpwm-contrib-build-system;
  # custom_quicklisp = quicklisp;
  # inherit quicklisp;
  #   mcclim
  #   stumpwm-git-new
  #   stumpwm-contrib
  #   stumpwm-contrib-stumpish
  #   quicklisp
  #   slynk-quicklisp
  #   ;
  # sbcl_custom = sbcl;
}
