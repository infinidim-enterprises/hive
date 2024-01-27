{ sources, buildGoApplication }:

buildGoApplication {
  inherit (sources.k9s) pname version src;
  modules = ./gomod2nix.toml;
}
