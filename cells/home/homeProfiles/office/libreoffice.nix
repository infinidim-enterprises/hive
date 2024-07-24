{ pkgs, ... }:
{
  home.packages = with pkgs; [
    libreoffice
    (hunspellWithDicts
      (with hunspellDicts; [
        ru_RU
        en_US-large
        en_GB-ize
        en_GB-large
        de_DE
        he_IL
      ]))
  ];
}
