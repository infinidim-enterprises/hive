{ inputs, cell, ... }:

final: prev:
let
  inherit (prev.python3Packages) callPackage;
in
{
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (
      python-final: python-prev: {
        python-gnupg = python-prev.python-gnupg.overridePythonAttrs (oldAttrs: {
          inherit (final.sources.python-gnupg) src version pname;
        });

        ledgerblue = python-prev.ledgerblue.overridePythonAttrs (oldAttrs: {
          inherit (final.sources.ledgerblue) src pname;
          version = "0.1.49";
          pyproject = true;
          format = null;
          nativeBuildInputs = with python-prev; [ setuptools setuptools-scm ];
          propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ python-final.python-gnupg ];
          /*

          ###
          # NOTE: implement SYMLINK+="ledger%n"
          # https://raw.githubusercontent.com/trezor/trezor-common/master/udev/51-trezor.rules
          ###

            future # there's version 1.0.0 https://github.com/PythonCharmers/python-future
            hidapi
            nfcpy
            pillow
            protobuf
            pycrypto
            pycryptodomex
            pyelftools
            python-u2flib-host
            websocket-client
            # bleak is isLinux
          */
        });
      }
    )
  ];

}
