{ lib
, fetchFromGitHub
, callPackage
, rustPlatform
, makeWrapper
, pkg-config
, perl
, openssl
, python3
, qt6
, substituteAll
, buildNpmPackage
}:

let
  version = "0.12.1";
  sources = fetchFromGitHub {
    owner = "ActivityWatch";
    repo = "activitywatch";
    rev = "v${version}";
    sha256 = "sha256-pK+upMSpJlg7J8WTmImLm8TW8pMHrCihMeiT+1/nbPM=";
    fetchSubmodules = true;
  };
  watchers = callPackage ./watchers.nix { };
in
rec {
  inherit (watchers) aw-watcher-afk aw-watcher-window;

  aw-qt = python3.pkgs.buildPythonApplication {
    pname = "aw-qt";
    inherit version;

    format = "pyproject";

    src = "${sources}/aw-qt";

    nativeBuildInputs = [
      python3.pkgs.poetry
      qt6.wrapQtAppsHook
    ];

    propagatedBuildInputs = with python3.pkgs; [
      aw-core
      qt6.qtbase # Needed for qt6.wrapQtAppsHook
      qt6.qtsvg # Rendering icons in the trayicon menu
      pyqt6
      click
    ];

    # Prevent double wrapping
    dontWrapQtApps = true;

    postPatch = ''
      sed -E 's#PyQt6 = "6.3.1"#PyQt6 = "^6.4.0"#g' -i pyproject.toml
    '';

    postInstall = ''
      install -D resources/aw-qt.desktop $out/share/applications/aw-qt.desktop
      install -D resources/aw-qt.desktop $out/etc/xdg/autostart/aw-qt.desktop

      # For the actual tray icon, see
      # https://github.com/ActivityWatch/aw-qt/blob/8ec5db941ede0923bfe26631acf241a4a5353108/aw_qt/trayicon.py#L211-L218
      install -D media/logo/logo.png $out/lib/python3.10/site-packages/media/logo/logo.png

      # For .desktop file and your desktop environment
      install -D media/logo/logo.svg $out/share/icons/hicolor/scalable/apps/activitywatch.svg
      install -D media/logo/logo.png $out/share/icons/hicolor/512x512/apps/activitywatch.png
      install -D media/logo/logo-128.png $out/share/icons/hicolor/128x128/apps/activitywatch.png
    '';

    preFixup = ''
      makeWrapperArgs+=(
        "''${qtWrapperArgs[@]}"
      )
    '';

    meta = with lib; {
      description = "Tray icon that manages ActivityWatch processes, built with Qt";
      homepage = "https://github.com/ActivityWatch/aw-qt";
      maintainers = with maintainers; [ jtojnar ];
      license = licenses.mpl20;
    };
  };

  aw-server-rust = rustPlatform.buildRustPackage {
    name = "aw-server-rust";
    inherit version;

    src = "${sources}/aw-server-rust";

    cargoHash = "sha256-KWefX7AU+nOWy5cmE9FYAG6OToWYQ72gBaDqrtJCzxM=";

    # Bypass rust nightly features not being available on rust stable
    RUSTC_BOOTSTRAP = 1;

    nativeBuildInputs = [
      makeWrapper
      pkg-config
      perl
    ];

    buildInputs = [
      openssl
    ];

    postFixup = ''
      wrapProgram "$out/bin/aw-server" \
        --prefix XDG_DATA_DIRS : "$out/share"

      mkdir -p "$out/share/aw-server"
      ln -s "${aw-webui}" "$out/share/aw-server/static"
    '';

    preCheck = ''
      # Fake home folder for tests that use ~/.cache and ~/.local/share
      export HOME="$TMP/fake-test-home"
    '';

    meta = with lib; {
      description = "High-performance implementation of the ActivityWatch server, written in Rust";
      homepage = "https://github.com/ActivityWatch/aw-server-rust";
      maintainers = with maintainers; [ jtojnar ];
      mainProgram = "aw-server";
      platforms = platforms.linux;
      license = licenses.mpl20;
    };
  };

  aw-webui = buildNpmPackage {
    pname = "aw-webui";
    inherit version;

    src = "${sources}/aw-server-rust/aw-webui";

    npmDepsHash = "sha256-wXAUJrzghUnN3+4NPCqerzdKzANsTFtyJF/IoSVtG70=";

    patches = [
      # Hardcode version to avoid the need to have the Git repo available at build time.
      (substituteAll {
        src = ./commit-hash.patch;
        commit_hash = sources.rev;
      })
    ];

    installPhase = ''
      runHook preInstall
      mv dist $out
      runHook postInstall
    '';

    meta = with lib; {
      description = "A web-based UI for ActivityWatch, built with Vue.js";
      homepage = "https://github.com/ActivityWatch/aw-webui/";
      maintainers = with maintainers; [ jtojnar ];
      license = licenses.mpl20;
    };
  };
}
