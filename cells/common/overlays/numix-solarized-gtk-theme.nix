{ ... }:

final: prev:
let
  inherit (prev.python3Packages) callPackage;
  haishokuPkg = { lib, buildPythonPackage, pillow }:
    buildPythonPackage {
      inherit (final.sources.misc.haishoku) pname src version;

      propagatedBuildInputs = [ pillow ];
      doCheck = false;
      pythonImportsCheck = [ "haishoku" ];

      meta = with lib; {
        description = "Tool for grabbing dominant color palette from images";
        homepage = "https://github.com/LanceGin/haishoku";
        license = licenses.mit;
        platforms = platforms.unix;
      };
    };

  colorzPkg = { lib, buildPythonPackage, pillow, scipy }:
    buildPythonPackage {
      inherit (final.sources.misc.colorz) pname src version;

      propagatedBuildInputs = [ pillow scipy ];
      doCheck = false;
      pythonImportsCheck = [ "colorz" ];

      meta = with lib; {
        description = "Python color scheme generator";
        homepage = "https://github.com/metakirby5/colorz";
        license = licenses.mit;
        platforms = platforms.unix;
      };
    };

in

{
  numix-solarized-gtk-theme = prev.numix-solarized-gtk-theme.overrideAttrs (_: {
    inherit (final.sources.misc.numix-solarized-gtk-theme-git) src version;
  });

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (python-final: python-prev: {
      haishoku = callPackage haishokuPkg { };
      colorz = callPackage colorzPkg { };
    })
  ];

  themix-gui = prev.themix-gui.overrideAttrs
    (old: rec {
      inherit (final.sources.misc.themix-gui) src version;
      # NOTE: https://github.com/themix-project/themix-gui/blob/master/docs_markdown/Manual_Installation.md
      propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ (with prev; [
        xorg.xrdb
        findutils
        gnused
        gnugrep
        bc
        zip
        libsForQt5.breeze-icons
        # breeze-icons
        polkit
        polkit_gnome
        librsvg
        inkscape
        imagemagick
        sassc
        gdk-pixbuf
        optipng
        gtk-engine-murrine
        parallel
        glib
      ]);

      preFixup =
        let
          paths = prev.lib.makeBinPath (propagatedBuildInputs ++ (with prev; [
            meson
            gnumake
            glib.dev
            gdk-pixbuf.dev
          ]));
        in
        ''
          gappsWrapperArgs+=(--prefix PATH : "${paths}")
        '';

      postPatch =
        let
          py = prev.lib.getExe (prev.python3.withPackages (p: with p; [
            pygobject3
            pillow
            pyaml
            pystache
            colorthief
            haishoku
            colorz
          ]));
          gt = "${prev.gettext}/bin/xgettext";
          msginit = "${prev.gettext}/bin/msginit";
          msgmerge = "${prev.gettext}/bin/msgmerge";
          msgfmt = "${prev.gettext}/bin/msgfmt";
          shfilesArray = "readarray -d '' shfiles < <(find . -type f -name change_color.sh -print0)";
        in
        ''
          local -a shfiles

          substituteInPlace gui.sh packaging/bin/{oomox,themix}-gui --replace-fail python3 ${py}
          substituteInPlace Makefile --replace-fail ${prev.lib.escapeShellArg "$(shell which python3)"} ${py}

          substituteInPlace po.mk --replace-fail "xgettext" ${gt} \
            --replace-fail "msginit" ${msginit} \
            --replace-fail "msgmerge" ${msgmerge} \
            --replace-fail "msgfmt" ${msgfmt}

          ${shfilesArray}
          for shfile in "''${shfiles[@]}"; do
            substituteInPlace "$shfile" --replace-fail 'cp ' 'cp --no-preserve=mode '
          done
        '';

      installPhase = ''
        runHook preInstall

        make DESTDIR=/ APPDIR=$out/opt/oomox PREFIX=$out install
        python -O -m compileall $out/opt/oomox/oomox_gui -d /opt/oomox/oomox_gui

        make -f po.mk install

        runHook postInstall
      '';
    });
}
