{ inputs, cell, ... }:

final: prev:
let
  inherit (prev.python3Packages) callPackage;
in
{
  # TODO: promnesia = callPackage ../packages/tools/python/promnesia {
  #   orgparse = final.orgparse;
  #   hpi = final.hpi;
  # };
  # orgparse = callPackage ../packages/tools/python/orgparse { };
  # hpi = callPackage ../packages/tools/python/HPI { };

  ###
  # TODO: chatgpt-wrapper = callPackage ../packages/tools/python/chatgpt-wrapper { };
  # langchain = callPackage ../packages/tools/python/langchain { };
  ###

  # Emacs plugin, based on chatGPT
  # mind-wave = final.poetry2nix.mkPoetryEnv { projectDir = ../packages/tools/python/mind-wave; };
  # NOTE: [Closed] https://github.com/NixOS/nixpkgs/issues/288478

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (python-final: python-prev: {
      iterable-io = callPackage ../packages/tools/python/iterable-io { };
      magic-wormhole = python-prev.magic-wormhole.overridePythonAttrs (oldAttrs: {
        propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
          python-prev.zipstream-ng
          python-final.iterable-io
        ];
      });
    })

    # FIXME: pynitrokey
    # (python-final: python-prev: {
    #   pynitrokey = python-prev.pynitrokey.overridePythonAttrs (oldAttrs: {
    #     inherit (final.sources.misc.pynitrokey) src version pname;
    #     buildInputs = oldAttrs.buildInputs or [ ] ++ [ python-prev.poetry-core ];
    #   });
    # })

    (python-final: python-prev: {
      pypass = python-prev.pypass.overridePythonAttrs (oldAttrs: {
        inherit (final.sources.python-pass) src version pname;
        doCheck = false;
        patches = [
          (with prev; substituteAll {
            # NOTE: https://github.com/aviau/python-pass/pull/34
            # https://github.com/nazarewk-iac/nix-configs/blob/main/packages/pass-secret-service/default.nix
            # NOTE: maybe switch to this - https://github.com/mdellweg/pass_secret_service/pull/37
            src = ./pypass-mark-executables.patch;
            version = "0.2.2dev";
            git_exec = "${git}/bin/git";
            grep_exec = "${gnugrep}/bin/grep";
            gpg_exec = "${gnupg}/bin/gpg2";
            tree_exec = "${tree}/bin/tree";
            xclip_exec = "${xclip}/bin/xclip";
          })
        ];

      });
    })

  ];

}
