{ inputs, cell, ... }:
final: prev:

{
  # NOTE: [Closed] https://github.com/NixOS/nixpkgs/issues/288478
  # pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
  #   (python-final: python-prev: {
  #     grip = python-prev.grip.overridePythonAttrs (oldAttrs: {
  #       inherit (final.sources-emacs.grip) src pname version;
  #     });
  #   })
  # ];
}
