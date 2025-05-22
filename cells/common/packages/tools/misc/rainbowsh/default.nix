{ lib, stdenv, sources }:

stdenv.mkDerivation rec {
  inherit (sources.shell.rainbowsh) src pname version;

  phases = [ "unpackPhase" "installPhase" ];
  doCheck = false;

  installPhase = ''
    mkdir -p $out
    install -D -m 0644 rainbow.sh $out
  '';

  meta = with lib; {
    description = "Colors for your scripts, the easy way.";
    homepage = "https://github.com/xr09/rainbow.sh";
    platforms = platforms.unix;
    license = licenses.mit;
  };
}
