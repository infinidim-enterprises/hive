{ lib
, sources
, glib
, stdenvNoCC
, gtk-engine-murrine
}:

stdenvNoCC.mkDerivation {
  inherit (sources.solarized-dark-gnome-shell-2020) pname version src;
  nativeBuildInputs = [
    glib # glib-compile-resources
  ];

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  installPhase = ''
    runHook preInstall

    for theme in $(find $src -maxdepth 1 -type d ! -path $src); do
      name=$(basename $theme)
      target_dir="$out/share/themes/$name"
      mkdir -p $target_dir
      cp -r $theme/* $target_dir
      mkdir -p $target_dir/gdm
      cd $target_dir/gnome-shell
      glib-compile-resources --target=$target_dir/gdm/gnome-shell-theme.gresource gnome-shell-theme.gresource.xml
    done

    runHook postInstall
  '';
}
