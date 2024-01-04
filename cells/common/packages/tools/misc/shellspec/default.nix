{ lib, stdenv, sources }:

stdenv.mkDerivation rec {
  inherit (sources.shellspec) src pname version;

  phases = [ "unpackPhase" "installPhase" ];
  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A full-featured BDD unit testing framework for bash, ksh, zsh, dash and all POSIX shells ";
    homepage = https://github.com/shellspec/shellspec;
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
