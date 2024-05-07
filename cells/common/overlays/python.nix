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
  ];

}
