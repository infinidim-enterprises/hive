{ inputs, cell, ... }:

inputs.haumea.lib.load {
  src = ./overlays;
  inputs = { inherit inputs cell; };
  transformer = inputs.haumea.lib.transformers.liftDefault;
}
