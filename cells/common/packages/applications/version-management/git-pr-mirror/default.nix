{ lib, buildGoModule, sources }:

buildGoModule rec {
  inherit (sources.git-pr-mirror) src pname version vendorSha256;

  postInstall = ''
    for bin in $out/bin/*; do
      mv $bin $out/bin/git-pr-$(basename $bin)
    done
  '';

  meta = with lib; {
    description = "Mirror Github Pull Requests into the git-pull-request-mirror formats";
    homepage = "https://github.com/google/git-pull-request-mirror";
    license = licenses.asl20;
    platforms = platforms.all;
    maintainers = [ ];
  };
}
