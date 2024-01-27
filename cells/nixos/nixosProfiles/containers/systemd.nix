{ inputs, cell, ... }:

{ self, suites, ... }:

{
  imports = with self; [
    { _module.args.self = self; }
    nixosModules.zerotierone
    nixosModules.deploy
    inputs.ragenix.nixosModules.age
    inputs.home.nixosModules.home-manager
  ] ++ suites.networking;

  nixpkgs.config.allowUnfree = true;
}
