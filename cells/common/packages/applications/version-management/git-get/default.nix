{ sources, lib, buildGoModule, makeWrapper }:

buildGoModule rec {
  inherit (sources.git-get) pname version src vendorHash;

  nativeBuildInputs = [ makeWrapper ];
  postInstall = ''
    mkdir -p $out/bin
    wrapProgram $out/bin/get
    wrapProgram $out/bin/list
    mv $out/bin/get  $out/bin/git-get
    mv $out/bin/list $out/bin/git-list
  '';

  doCheck = false;

  meta = with lib; {
    platforms = platforms.unix;
  };
}
