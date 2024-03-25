{ config, lib, pkgs, name, osConfig, ... }:
with lib; with builtins;
let
  cfgSecurity = config.accounts.security;

  tmpl8 = pkgs.substituteAll {
    src = ./gpg_template.txt;

  };

  gpg_template = let quotes = "''"; in
    pkgs.writeText "gpg_template.nix" ''
      passphrase:
      let str = ${quotes}
      %echo Generating a basic OpenPGP key
      Key-Type: ${cfgSecurity.gpg.key_type}
      Key-Length: ${toString (cfgSecurity.gpg.key_length)}
      Key-Usage: cert
      Name-Real: ${cfgSecurity.gpg.real_name}
      Name-Comment: And thanks for all the fish
      Name-Email: ${name}@${osConfig.networking.domain}
      Expire-Date: 0
      Passphrase: ''${passphrase}
      # Do a commit here, so that we can later print "done" :-)
      %commit
      %echo done
      ${quotes};
      in str
    '';
  # https://raymii.org/s/articles/GPG_noninteractive_batch_sign_trust_and_send_gnupg_keys.html
  mk_gpg_key = let gpg_cmd_base = "gpg --status-fd 1 --quiet --batch --pinentry-mode loopback --passphrase \"$1\""; in
    pkgs.writeShellScriptBin "mk_gpg_key" ''
      export GNUPGHOME="$(mktemp -d)"
      temp_loc="$(mktemp -d)"
      nix eval --raw --impure --expr "import ${gpg_template} \"$1\"" > $temp_loc/template.txt
      gpg --batch --generate-key $temp_loc/template.txt

      FPR=$(gpg --list-secret-keys --with-colons | awk -F: '/fpr:/ {print $10}')
      SECRET_FILE_KEYS="$temp_loc/''${FPR}_secret-keys.txt"
      SECRET_FILE_SUBKEYS="$temp_loc/''${FPR}_secret-subkeys.txt"

      for i in sign encrypt auth
      do
        ${gpg_cmd_base} --quick-add-key $FPR rsa4096 $i never &> /dev/null
      done

      # backup master key
      ${gpg_cmd_base} --armor --output $SECRET_FILE_KEYS --export-secret-key $FPR &> /dev/null
      # export subkeys
      ${gpg_cmd_base} --armor --output $SECRET_FILE_SUBKEYS --export-secret-subkeys $FPR &> /dev/null

      # remove the original
      # gpg --status-fd 1 --quiet --batch --yes --delete-secret-key $FPR &> /dev/null
      # import the subkeys
      # ${gpg_cmd_base}  --import $SECRET_FILE_SUBKEYS &> /dev/null

      echo "export GNUPGHOME=$GNUPGHOME"
      echo "Keys in $temp_loc"
    '';

  enc_with_passwd = pkgs.writeShellScriptBin "enc_with_passwd" ''
    gpg --symmetric --cipher-algo AES256 --s2k-digest-algo SHA512 $1
  '';

in
{
  options.accounts.security = with types; {
    enable = mkEnableOption "Hardware keys/templates etc..." // { default = true; };
    gpg.key_type = mkOption { default = "RSA"; type = str; };
    gpg.key_length = mkOption { default = 4096; type = int; };
    gpg.real_name = mkOption { default = null; type = nullOr str; apply = s: if s != null then s else name; };
    gpg.expiration_date = mkOption { default = ""; type = str; };
  };
  config = mkMerge [ (mkIf cfgSecurity.enable { home.packages = [ pkgs.gnupg mk_gpg_key ]; }) ];
}
