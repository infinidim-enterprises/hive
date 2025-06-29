{ config, lib, pkgs, ... }:

{
  programs.gpg.enable = true;
  programs.gpg.mutableKeys = true;
  programs.gpg.mutableTrust = true;
  # FIXME: this should be per user: gpg.publicKeys, gpg-agent.sshKeys
  programs.gpg.publicKeys = [
    {
      source = ./D299B0B3CCB1D97714DAD6A154CA4193F1572167_public_key.asc;
      trust = "ultimate"; # yk5
    }
    {
      source = ./382A371CFB344166F69076BE8587AB791475DF76_public_key.asc;
      trust = "ultimate"; # nitrokey
    }
    {
      source = ./E3C4C12EDF24CA20F167CC7EE203A151BB3FD1AE_public_key.asc;
      trust = "ultimate"; # yk4
    }
  ];

  services.gpg-agent.sshKeys = [
    "BF937D664B4676554055CE7921AD95A76A2AA57C" # yk5
    "1953CEBFBC2D71B3CA498433F7EFDE2FDC1E69C5" # nitrokey
    "E3C4C12EDF24CA20F167CC7EE203A151BB3FD1AE" # yk4
  ];
}
