{
  inputs,
  cell,
  ...
}: final: prev: let
  inherit (prev.python3Packages) callPackage;
in {
  promnesia = callPackage ../packages/tools/python/promnesia {
    orgparse = final.orgparse;
    hpi = final.hpi;
  };
  orgparse = callPackage ../packages/tools/python/orgparse {};
  hpi = callPackage ../packages/tools/python/HPI {};

  ###
  # TODO: chatgpt-wrapper = callPackage ../packages/tools/python/chatgpt-wrapper { };
  # langchain = callPackage ../packages/tools/python/langchain { };
  ###

  # Emacs plugin, based on chatGPT
  mind-wave = final.poetry2nix.mkPoetryEnv {projectDir = ../packages/tools/python/mind-wave;};
}
