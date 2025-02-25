{ inputs, cell, ... }:
{
  vultr = { lib, config, pkgs, ... }:
    let
      inherit (config.networking) hostName;
    in
    {
      imports = [
        inputs.cells.services.nixosProfiles.atticd.default
        ./acme.nix
        {
          age.secrets.attic-cert.file = pkgs.lib.age.file "attic-cert.age";
          services.atticd = {
            credentialsFile = config.age.secrets."attic-cert".path;
            settings = {
              listen = "[::1]:57448";
              database.url = "postgresql:///attic?host=/run/postgresql";
              allowed-hosts = [ "attic.njk.li" ];
              api-endpoint = "https://attic.njk.li";
              storage = {
                type = "s3";
                region = "us-west-004";
                bucket = "njk-nix-cache";
                endpoint = "https://s3.us-west-004.backblazeb2.com";
              };
            };
          };
        }
      ];
      services.atticd.hiveProfiles = {
        psql = true;
      };
    };
}
