{lib, ...}:
with lib; let
  capitalize = {
    __functor = _self: str:
      concatStrings (
        imap0
        (i: s:
          if i == 0
          then toUpper s
          else s)
        (stringToCharacters str)
      );

    doc = ''
      Helper to capitalize strings
    '';
  };
in
  capitalize
