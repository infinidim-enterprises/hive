{ inputs, cell, ... }:

{ lib, config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ openldap ];

  security.pam.services.sshd = {
    makeHomeDir = true;
    # see https://stackoverflow.com/a/47041843 for why this is required

    text = lib.mkDefault (
      lib.mkBefore ''
        auth required pam_listfile.so \
          item=group sense=allow onerr=fail file=/etc/allowed_groups
      ''
    );

  };

  environment.etc.allowed_groups = {
    text = "admin";
    mode = "0444";
  };

  environment.etc."ldap/bind.password" = {
    text = "Nixos.123!";
    mode = "0444";
  };

  users.ldap = {
    enable = true;
    daemon.enable = true;

    bind.distinguishedName = "uid=gadmin,ou=Users,o=5fa952a8ab71a75cdb7fcf63,dc=jumpcloud,dc=com";
    bind.passwordFile = "/etc/ldap/bind.password";

    base = "ou=Users,o=5fa952a8ab71a75cdb7fcf63,dc=jumpcloud,dc=com";
    server = "ldap://ldap.jumpcloud.com";
    useTLS = true;
    # server = "ldaps://ldap.jumpcloud.com";

    extraConfig = ''
      ldap_version 3
      pam_password md5

      # TOFIX: this does not work for some reason
      # # https://serverfault.com/a/137996
      # nss_override_attribute_value loginShell /run/current-system/sw/bin/bash
    '';

  };

  # evil, horrifying hack for dysfunctional nss_override_attribute_value
  systemd.tmpfiles.rules = [
    "L /bin/bash - - - - /run/current-system/sw/bin/bash"
  ];
}
