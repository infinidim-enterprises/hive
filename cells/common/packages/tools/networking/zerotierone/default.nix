{ lib
, stdenv
, buildPackages
, lzo
, openssl
, pkg-config
, ronn
, zlib
, libiconv
, sources
}:

stdenv.mkDerivation {
  inherit (sources.zerotierone) pname version src;

  preConfigure = ''
    patchShebangs ./doc/build.sh
    substituteInPlace ./doc/build.sh \
      --replace '/usr/bin/ronn' '${buildPackages.ronn}/bin/ronn' \

    substituteInPlace ./make-linux.mk \
      --replace '-march=armv6zk' "" \
      --replace '-mcpu=arm1176jzf-s' ""

    mkdir -p $out/share/bash-completion/completions
    cp ./zerotier-cli-completion.bash $out/share/bash-completion/completions/zerotier-cli
  '';

  nativeBuildInputs = [
    pkg-config
    ronn
  ];

  buildInputs =
    [
      lzo
      openssl
      zlib
    ];

  enableParallelBuilding = true;

  makeFlags = [ "ZT_SSO_SUPPORTED=0" ];

  buildFlags = [
    "ZT_SSO_SUPPORTED=0"
    "all"
    "selftest"
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  checkPhase = ''
    runHook preCheck
    ./zerotier-selftest
    runHook postCheck
  '';

  installFlags = [
    "-f"
    "make-linux.mk"
    "DESTDIR=$$out/upstream"
  ];

  postInstall = ''
    mv $out/upstream/usr/sbin $out/bin

    mkdir -p $man/share
    mv $out/upstream/usr/share/man $man/share/man

    rm -rf $out/upstream
  '';

  outputs = [
    "out"
    "man"
  ];

  meta = with lib; {
    description = "Create flat virtual Ethernet networks of almost unlimited size";
    homepage = "https://www.zerotier.com";
    platforms = platforms.linux;
  };
}
