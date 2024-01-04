{ buildGoPackage, sources }:
buildGoPackage {
  inherit (sources.gitea-tea) pname src version;
  goPackagePath = "code.gitea.io/tea";
}
