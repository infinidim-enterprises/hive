{ lib
, monkeysphere
, python3Packages
, gnupg
, gnused
, gnugrep
, coreutils
, gawk
, sources
}:

# FIXME: assert lib.assertMsg ((lib.trivial.revisionWithDefault null) == "e1d501922fd7351da4200e1275dfcf5faaad1220")
#   "gpg-hd is pinned to e1d501922fd7351da4200e1275dfcf5faaad1220, but we're running on ${toString (lib.trivial.revisionWithDefault null)}";

python3Packages.buildPythonPackage {
  inherit (sources.gpg-hd) pname version src;
  format = "other";
  doCheck = false;
  propagatedBuildInputs = with python3Packages; [
    pycrypto
    pexpect

    gawk
    gnupg
    gnugrep
    coreutils
    monkeysphere
  ];

  buildPhase = ''
    echo DUMMY-BUILD-PHASE
  '';

  installPhase = ''
    mkdir -p $out/bin
    cat $src/gpg-hd | sed 's|/usr/bin/env python3|${python3Packages.python}/bin/python|g' > $out/bin/gpg-hd
    ln -s $src/hmac_drbg.py $out/bin/hmac_drbg.py
    chmod 0755 $out/bin/gpg-hd
  '';
  meta.mainProgram = "gpg-hd";
}
