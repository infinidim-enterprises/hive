{ lib, stdenv, sources }:

stdenv.mkDerivation rec {
  inherit (sources.getoptions) pname src version;

  phases = [ "installPhase" ];
  doCheck = false;

  installPhase = ''
    mkdir -p $out
    for libFile in $(ls $src/lib/*.sh)
    do
      install -D -m 755 $libFile $out
    done
  '';

  meta = with lib; {
    description = "An elegant option parser for shell scripts (sh, bash and all POSIX shells)";
    homepage = https://github.com/ko1nksm/getoptions;
    license = licenses.cc0;
    platforms = platforms.unix;
  };
}
