{ lib, ... }:
{
  programs.git.settings.user.name = "Voob of Doom";
  programs.git.settings.user.email = "voobofdoom@njk.li";
  programs.git.signing.key = lib.mkDefault "D299B0B3CCB1D97714DAD6A154CA4193F1572167";
  # programs.git.signing.key = lib.mkDefault "382A371CFB344166F69076BE8587AB791475DF76";
  # programs.git.signing.key = lib.mkDefault "E3C4C12EDF24CA20F167CC7EE203A151BB3FD1AE";
  programs.git.settings.github.user = "voobscout";
}
