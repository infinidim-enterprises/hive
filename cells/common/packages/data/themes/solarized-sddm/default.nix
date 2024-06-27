{ lib
, sources
, stdenvNoCC
, writeText
, rsync
, qt5
, themeConfig ? {
    General.background = "bars_background.png";
    General.displayFont = "UbuntuMono Nerd Font Mono";
  }
}:
let
  theme_conf = writeText "theme_conf"
    (lib.generators.toINI { } themeConfig);
in
stdenvNoCC.mkDerivation rec {
  inherit (sources.solarized-sddm) pname version src;

  buildInputs = [ rsync ];
  propagatedBuildInputs = [ qt5.qtgraphicaleffects ];
  dontWrapQtApps = true;
  installPhase = ''
    runHook preInstall

    dst="$out/share/sddm/themes/${pname}"
    mkdir -p "$dst"

    rsync -av --exclude='theme.conf' $src/* $dst
    cp ${theme_conf} "$dst/theme.conf"

    runHook postInstall
  '';

  postFixup = ''
    mkdir -p $out/nix-support

    echo ${qt5.qtgraphicaleffects} >> $out/nix-support/propagated-user-env-packages
  '';

}
