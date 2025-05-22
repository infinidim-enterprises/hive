{ sources, stdenv }:
stdenv.mkDerivation rec {
  inherit (sources.emacs.all-the-icons) version src pname;
  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/share/fonts/truetype/all-the-icons
    cd $src
    find -name \*.ttf -exec mv {} $out/share/fonts/truetype/all-the-icons \;
  '';
}
