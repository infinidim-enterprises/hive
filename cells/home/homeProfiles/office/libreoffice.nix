{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # TODO: vendor libreoffice
    libreoffice # -fresh
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
