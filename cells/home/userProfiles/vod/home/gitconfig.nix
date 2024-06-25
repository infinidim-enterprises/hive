{ lib, ... }:
{
  programs.git.userName = "Voob of Doom";
  programs.git.userEmail = "v@njk.li";
  programs.git.signing.key = lib.mkDefault "382A371CFB344166F69076BE8587AB791475DF76";
  # programs.git.signing.key = "E3C4C12EDF24CA20F167CC7EE203A151BB3FD1AE";
  programs.git.extraConfig.github.user = "voobscout";
}
