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

    mkdir -p $out/share/themes/Solarized-Dark-Green-GS-3.36/gnome-shell

    cd $src/Solarized-Dark-Green-GS-3.36/gnome-shell
    glib-compile-resources --target=$out/share/themes/Solarized-Dark-Green-GS-3.36/gnome-shell/gnome-shell-theme.gresource gnome-shell-theme.gresource.xml

    runHook postInstall
  '';
  /*
    mkdir -p $out/share/gnome-shell

     $src/Solarized-Dark-Green-GS-3.36/gnome-shell/
    cd $src/Solarized-Dark-Green-GS-3.36
    mkdir -p $out/share/themes/${themeName}


    GTK_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme | sed "s/'//g")
    cd /usr/share/themes/${GTK_THEME}/gnome-shell

  */
}
