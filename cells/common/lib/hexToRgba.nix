{ lib, ... }:
let
  inherit (lib // builtins)
    stringToCharacters
    toLower
    imap0
    length
    foldl'
    removePrefix
    stringLength
    fromJSON
    toString
    substring;

  hexMap = { "0" = 0; "1" = 1; "2" = 2; "3" = 3; "4" = 4; "5" = 5; "6" = 6; "7" = 7; "8" = 8; "9" = 9; "a" = 10; "b" = 11; "c" = 12; "d" = 13; "e" = 14; "f" = 15; "A" = 10; "B" = 11; "C" = 12; "D" = 13; "E" = 14; "F" = 15; };

  hexCharToDec = c:
    hexMap.${c} or (throw "Invalid hex character: ${c}");

  pow = base: exp:
    if exp == 0
    then 1
    else base * (pow base (exp - 1));

  hexToDec = hex:
    let
      chars = stringToCharacters (toLower hex);
      values = imap0 (i: c: hexCharToDec c * pow 16 (length chars - i - 1)) chars;
    in
    foldl' (a: b: a + b) 0 values;

  hexToRgba = {
    __functor = _self:
      hex:

      let
        hexClean = removePrefix "#" hex;
        len = stringLength hexClean;
        validLength = len == 6 || len == 8;

        r = hexToDec (substring 0 2 hexClean);
        g = hexToDec (substring 2 2 hexClean);
        b = hexToDec (substring 4 2 hexClean);

        alpha =
          if len == 6
          then 1.0
          else
            let
              alphaHex = substring 6 2 hexClean;
              alphaDec = hexToDec alphaHex;
            in
            (fromJSON (toString alphaDec)) / 255.0;
      in

      if !validLength
      then throw "Invalid hex color length: must be 6 or 8 characters"
      else "rgba(${toString r}, ${toString g}, ${toString b}, ${toString alpha})";

    doc = ''
      Convert hex color values into rgba, the function takes either 6 or 8 hex chars

      Example:
      hexToRgba "#ff5733"
      =>
        "rgba(255, 87, 51, 1.000000)"

      Example:
      hexToRgba "#ff573322"
      =>
        "rgba(255, 87, 51, 0.133333)"
    '';
  };
in
hexToRgba
