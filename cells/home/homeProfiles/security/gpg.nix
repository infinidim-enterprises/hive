{ config, lib, pkgs, ... }:

{
  programs.gpg.enable = true;
  programs.gpg.mutableKeys = true;
  programs.gpg.mutableTrust = true;
  programs.gpg.publicKeys.vod.source = ./382A371CFB344166F69076BE8587AB791475DF76_public_key.asc;
  programs.gpg.publicKeys.vod.trust = "ultimate";

  services.gpg-agent.sshKeys = [ "1953CEBFBC2D71B3CA498433F7EFDE2FDC1E69C5" ];
}
