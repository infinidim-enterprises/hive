{ stdenv }:
stdenv.mkDerivation rec {
  # inherit (sources.all-the-icons) version src pname;
  src = ./windows-fonts.tar.gz;
  name = "windows-fonts";
  version = "latest";
  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out/share/fonts/truetype/windows-fonts
    find -name \*.ttf -exec mv {} $out/share/fonts/truetype/windows-fonts \;
  '';
}
