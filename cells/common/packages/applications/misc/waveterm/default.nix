{ lib
, fetchFromGitHub
, fetchYarnDeps
, buildGoModule
, mkYarnPackage
, electron_29
, makeWrapper
, copyDesktopItems
, makeDesktopItem
, breakpointHook
,
}:
let
  pname = "waveterm";
  version = "0.7.2";
  src = fetchFromGitHub {
    owner = "wavetermdev";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-NxUcBiwCK5ViAQVpx1P3pwvsr69p/ai/KztwZOFUt80=";
  };
  wavesrv = buildGoModule {
    inherit version src;
    preBuild = ''
      # go: 'go mod vendor' cannot be run in workspace mode. Run 'go work vendor' to vendor the workspace or set 'GOWORK=off' to exit workspace mode.
      # https://github.com/NixOS/nixpkgs/issues/203039
      export GOWORK="off";
    '';
    pname = "${pname}-wavesrv";
    modRoot = "./wavesrv";
    vendorHash = "sha256-1pUQ1yrdzsotvcX6ydomhlwFwl6TZTXAn/oL8a1p9MY=";
    doCheck = false; # Currently fails at comp_test.go:91: comp-fail: ls f[*] + [foo bar] => [ls foo\ bar [*]] expected[ls 'foo bar' [*]]
  };
  waveshell = buildGoModule {
    inherit version src;
    preBuild = ''
      # go: 'go mod vendor' cannot be run in workspace mode. Run 'go work vendor' to vendor the workspace or set 'GOWORK=off' to exit workspace mode.
      # https://github.com/NixOS/nixpkgs/issues/203039
      export GOWORK="off";
    '';
    pname = "${pname}-waveshell";
    modRoot = "./waveshell";
    vendorHash = "sha256-bkFv4hi4q36mJ9QUsKz00DdUZkRdx/JLJRutPcx+RLQ=";
  };
  electron = electron_29;
in
mkYarnPackage rec {
  inherit pname src version;

  packageJSON = "${src}/package.json";

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  offlineCache = fetchYarnDeps {
    yarnLock = "${src}/yarn.lock";
    hash = "sha256-LGh2KmqwBfpf6MC77ME9dx43Gg3RxTpd+KSBIkEbfT0=";
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
    breakpointHook
  ];

  buildPhase = ''
    runHook preBuild

    pushd deps/${pname}
    node_modules/.bin/webpack --env prod
    popd

    runHook postBuild
  '';

  postBuild = ''
    pushd deps/${pname}

    mkdir ./bin
    cp ${wavesrv}/bin/cmd ./bin/wavesrv.amd64
    mkdir ./bin/mshell
    cp ${waveshell}/bin/waveshell ./bin/mshell/mshell-v0.6-linux.amd64

    yarn --offline run electron-builder \
      --dir \
      -l \
      -p never \
      -c electron-builder.config.js \
      -c.electronDist=${electron}/libexec/electron \
      -c.electronVersion=${electron.version}

    popd
  '';

  installPhase = ''
    runHook preInstall

    # resources
    mkdir -p "$out/share/lib/${pname}"
    cp -r ./deps/${pname}/make/*-unpacked/{locales,resources{,.pak}} "$out/share/lib/${pname}"

    # icons
    #install -Dm644 ./deps/${pname}/static/Icon.png $out/share/icons/hicolor/1024x1024/apps/${pname}.png

    # executable wrapper
    makeWrapper '${electron}/bin/electron' "$out/bin/${pname}" \
      --add-flags "$out/share/lib/${pname}/resources/app.asar" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
      --inherit-argv0

    runHook postInstall
  '';
  # Do not attempt generating a tarball for contents again.
  # note: `doDist = false;` does not work.
  distPhase = "true";

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "Wave Terminal";
      genericName = "An Open-Source, AI-Native, Terminal Built for Seamless Workflows";
      comment = meta.description;
      categories = [ "System" ];
      startupWMClass = pname;
    })
  ];

  meta = with lib; {
    changelog = "https://github.com/wavetermdev/waveterm/releases/tag/${src.rev}";
    description = "An Open-Source, AI-Native, Terminal Built for Seamless Workflows";
    homepage = "https://github.com/wavetermdev/wavetermn";
    license = licenses.asl20;
    mainProgram = pname;
    inherit (electron.meta) platforms;
  };
}
