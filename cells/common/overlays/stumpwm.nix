# TODO: https://nixos.org/manual/nixpkgs/stable/#lisp
{ inputs, cell, ... }:

let
  nixpkgs-22-11 = import inputs.nixos-22-11 {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
    overlays = [ cell.overlays.sources ];
  };
in

final: prev:
let
  /*
    stumpwm = {
    pname = "stumpwm";
    version = "20211230-git";
    asds = [ "stumpwm" ];
    src = (createAsd {
      url = "http://beta.quicklisp.org/archive/stumpwm/2021-12-30/stumpwm-20211230-git.tgz";
      sha256 = "0bn0shmi5iappmgjzr5qy01yhd17dr1d195xspkv0qla3gqazhpa";
      system = "stumpwm";
      asd = "stumpwm";
    });
    systems = [ "stumpwm" ];
    lispLibs = [ (getAttr "alexandria" pkgs) (getAttr "cl-ppcre" pkgs) (getAttr "clx" pkgs) ];
    };

    */
  func_sig =
    { pname
    , version
    , src ? null
    , patches ? [ ]
    , # Native libraries, will be appended to the library path
      nativeLibs ? [ ]
    , # Java libraries for ABCL, will be appended to the class path
      javaLibs ? [ ]
    , # Lisp dependencies
      # these should be packages built with `build-asdf-system`
      lispLibs ? [ ]
    , # Lisp command to run buildScript
      lisp
    , # Some libraries have multiple systems under one project, for
      # example, cffi has cffi-grovel, cffi-toolchain etc.  By
      # default, only the `pname` system is build.
      #
      # .asd's not listed in `systems` are removed in
      # installPhase. This prevents asdf from referring to uncompiled
      # systems on run time.
      #
      # Also useful when the pname is differrent than the system name,
      # such as when using reverse domain naming.
      systems ? [ pname ]
    , # The .asd files that this package provides
      asds ? systems
    , # Other args to mkDerivation
      ...
    }: "";

  sbcl = nixpkgs-22-11.lispPackages_new.sbclWithPackages (pkgs:
    with pkgs; [
      cl-diskspace
      cl-mount-info
      xml-emitter
      xkeyboard
      usocket-server
      percent-encoding

      clim
      # slim
      cl-dejavu
      opticl
      cl-pdf
      py-configparser
      dexador
      str
      quri
      drakma
      yason
      alexandria
      closer-mop
      cl-ppcre
      cl-ppcre-unicode
      clx
      clx-truetype
      anaphora
      xembed
      dbus
      bordeaux-threads
      cl-strings
      cl-hash-util
      cl-shellwords
      listopia
      lparallel
      acl-compat
      cl-syslog
      log4cl
    ]);

  build-with-compile-into-pwd = attrs:
    with final.lib; let
      args = attrs // { lisp = "${sbcl}/bin/sbcl --script"; };

      build = (nixpkgs-22-11.lispPackages_new.build-asdf-system (args // { version = args.version + "-build"; })).overrideAttrs (o: {
        buildPhase = with builtins; ''
          mkdir __fasls
          export LD_LIBRARY_PATH=${makeLibraryPath o.nativeLibs}:$LD_LIBRARY_PATH
          export CLASSPATH=${makeSearchPath "share/java/*" o.javaLibs}:$CLASSPATH
          export CL_SOURCE_REGISTRY=$CL_SOURCE_REGISTRY:$(pwd)//
          export ASDF_OUTPUT_TRANSLATIONS="$(pwd):$(pwd)/__fasls:${storeDir}:${storeDir}"
          ${o.lisp} ${o.buildScript}
        '';
        installPhase = ''
          mkdir -pv $out
          rm -rf __fasls
          cp -r * $out
        '';
      });
    in
    nixpkgs-22-11.lispPackages_new.build-asdf-system (args
      // {
      # Patches are already applied in `build`
      patches = [ ];
      src = build;
    });

  dynamic-mixins = build-with-compile-into-pwd rec {
    inherit (prev.lispPackages_new.sbclPackages.mcclim) version;
    pname = "dynamic-mixins-swm";
    src = "${final.sources.stumpwm-git.src}/dynamic-mixins";
    systems = [ "dynamic-mixins-swm" ];
    asds = systems;
    lispLibs = [ ];
  };

  mcclim = build-with-compile-into-pwd rec {
    inherit (prev.lispPackages_new.sbclPackages.mcclim) src version pname;
    systems = [ "mcclim" "mcclim-fonts" "mcclim-fonts/truetype" ];
    asds = systems;
    lispLibs = [ ];
  };

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

  slynk-quicklisp = prev.lispPackages_new.build-asdf-system {
    lisp = "${sbcl}/bin/sbcl --load ${final.sources.quicklisp.src} --eval '(quicklisp-quickstart:install)' --script";
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

  stumpwmCustomBuild_binary = prev.stdenv.mkDerivation {
    inherit (final.sources.stumpwm-git) src version pname system asd;
    buildInputs = with prev; [
      autoconf
      automake
      makeWrapper
    ];

    # propagatedBuildInputs = [ sbcl ];
    # src = stumpwmCustomBuild_new_lispPackages;

    preConfigure = ''
      ./autogen.sh
      export HOME=$TMPDIR
    '';

    # SBCL_HOME = "${sbcl}/lib/sbcl";
    # CLASSPATH ${sbcl.CLASSPATH}
    # # --set CL_SOURCE_REGISTRY ${sbcl.CL_SOURCE_REGISTRY} \
    # postInstall = ''
    #   wrapProgram $out/bin/stumpwm --prefix SBCL_HOME : ${prev.lib.makeBinPath [ sbcl ]} \
    #     --set LD_LIBRARY_PATH ${sbcl.LD_LIBRARY_PATH} \
    #     --set CL_SOURCE_REGISTRY ${sbcl.CL_SOURCE_REGISTRY} \
    #     --set SBCL_HOME ${prev.sbcl}/lib/sbcl
    # '';
  };

  stumpwm-git-new = nixpkgs-22-11.lispPackages_new.sbclWithPackages (pkgs:
    with pkgs;
    (builtins.attrValues final.stumpwm-contrib)
    ++ [
      stumpwmCustomBuild_new_lispPackages

      slynk
      slynk-macrostep
      slynk-named-readtables
      slynk-asdf

      cl-diskspace
      cl-mount-info
      xml-emitter
      xkeyboard
      usocket-server
      percent-encoding

      clim
      # FIXME slim/mcclim
      cl-dejavu
      opticl
      cl-pdf
      py-configparser
      dexador
      str
      quri
      drakma
      yason
      alexandria
      closer-mop
      cl-ppcre
      cl-ppcre-unicode
      clx
      clx-truetype
      anaphora
      xembed
      dbus
      bordeaux-threads
      cl-strings
      cl-hash-util
      cl-shellwords
      listopia
      acl-compat
      cl-syslog
      log4cl
      dbus
    ]);

  stumpwmCustomBuild_new_lispPackages = nixpkgs-22-11.lispPackages_new.build-asdf-system {
    buildInputs = with prev; [ autoconf automake makeWrapper ];
    lisp = "${sbcl}/bin/sbcl --script";
    systems = [ "stumpwm" ];
    asds = [ "stumpwm" ];
    lispLibs = [ dynamic-mixins ];
    inherit (final.sources.stumpwm-git) src version pname system asd;
    nativeLibs = with prev; [ libfixposix ];
  };

  stumpwm-contrib-stumpish = with builtins;
    with prev.lib;
    prev.writeScriptBin
      "stumpish"
      (replaceStrings
        [ "/bin/sh" "xprop" "rlwrap" ]
        [ "${prev.bash}/bin/sh" "${prev.xorg.xprop}/bin/xprop" "${prev.rlwrap}/bin/rlwrap" ]
        (readFile "${final.sources.stumpwm-contrib.src}/util/stumpish/stumpish"));

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
in
{
  inherit
    mcclim
    stumpwm-git-new
    stumpwm-contrib
    stumpwm-contrib-stumpish
    quicklisp
    slynk-quicklisp
    ;
  sbcl_custom = sbcl;
}
