{ stdenv, openssl, sources }:

stdenv.mkDerivation rec {
  inherit (sources.pbkdf2-sha512) src pname version;
  buildInputs = [ openssl ];
  unpackPhase = ":";
  buildPhase = "cc -O3 -I${openssl.dev}/include -L${openssl.out}/lib ${src} -o pbkdf2-sha512 -lcrypto";
  installPhase = ''
    mkdir -p $out/bin
    install -m755 pbkdf2-sha512 $out/bin/pbkdf2-sha512
  '';

}
