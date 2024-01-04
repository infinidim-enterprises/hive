{ lib, buildGoModule, sources, git }:

buildGoModule rec {
  inherit (sources.git-remote-ipfs) src pname version vendorSha256;

  doCheck = false;
  checkInputs = [ git ];

  postInstall = ''
    ln -s $out/bin/git-remote-ipfs $out/bin/git-remote-ipns
  '';

  meta = with lib; {
    platforms = platforms.unix;
  };
}
