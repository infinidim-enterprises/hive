{ sources, lib, buildGoModule, buildGoPackage, makeWrapper }:

buildGoModule rec {
  inherit (sources.k3d-github) pname version src;

  # goDeps = ./deps.nix;
  # goPackagePath = "github.com/k3d-io/k3d/v5";
  vendorSha256 = null;
  nativeBuildInputs = [ makeWrapper ];
  # postInstall = ''
  #   mkdir -p $out/bin
  #   wrapProgram $out/bin/get
  #   wrapProgram $out/bin/list
  #   mv $out/bin/get  $out/bin/git-get
  #   mv $out/bin/list $out/bin/git-list
  # '';

  # doCheck = false;

  meta = with lib; {
    platforms = platforms.unix;
  };
}
