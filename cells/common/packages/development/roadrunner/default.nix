{ sources
, buildGoPackage
, buildGo117Package
, buildGoModule
, buildGoApplication
, makeWrapper
}:

# buildGoApplication {
#   inherit (sources.roadrunner) src pname version;
#   modules = ./gomod2nix.toml;
# }

buildGo117Package {
  inherit (sources.roadrunner) src pname version;
  subPackages = [ "cmd/rr" ];
  goPackagePath = [ "github.com/roadrunner-server/roadrunner/v2" ];
  goDeps = ./deps.nix;
}

# buildGoPackage {
#   inherit (sources.roadrunner) src pname version;
#   subPackages = [ "cmd/rr" ];
#   goPackagePath = [ "github.com/roadrunner-server/roadrunner" ];
#   goDeps = ./deps.nix;

#   # vendorSha256 = "sha256-yzvFo+vK/ei1qQx6g7ac8yvBSL1A/NVDZB9cxUrweSY=";
#   # vendorSha256 = "";

#   # subPackages = [ "." ];
#   #subPackages = [ "cmd/rr" ];

#   # allowGoReference = true;

#   # doCheck = false;
#   # nativeBuildInputs = [ makeWrapper ];
#   # sourceRoot
#   # vendorSha256 = null;


#   # proxyVendor = true;
#   # ldFlags = [ "-s" ];
# }
