{ cell, inputs, ... }:

(inputs.flakelib.inputs.haumea.lib.load {
  src = ./overlays;
  inputs = { inherit inputs cell; };
  transformer = inputs.flakelib.inputs.haumea.lib.transformers.liftDefault;
})
