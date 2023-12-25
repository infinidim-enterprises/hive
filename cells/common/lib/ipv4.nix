{ lib, ... }:
let
  ip = {
    __functor = _self: a: b: c: d: prefixLength: {
      inherit a b c d prefixLength;
      address = "${toString a}.${toString b}.${toString c}.${toString d}";
    };
    doc = ''
      Returns a set of network attributes from multiple strings and/or digits
      Example:
        ip
    '';
  };

  toInt = {
    __functor = _self: addr: with addr; a * 16777216 + b * 65536 + c * 256 + d;
    doc = ''
      Integer representation of IP address
    '';
  };

  fromInt = {
    __functor = _self: addr: prefixLength:
      let
        aBlock = a * 16777216;
        bBlock = b * 65536;
        cBlock = c * 256;
        a = addr / 16777216;
        b = (addr - aBlock) / 65536;
        c = (addr - aBlock - bBlock) / 256;
        d = addr - aBlock - bBlock - cBlock;
      in
      ip a b c d prefixLength;
    doc = ''
      Returns a set of network attributes from an Integer representation, expects prefixLength
    '';
  };

  toCIDR = {
    __functor = _self: addr: "${addr.address}/${toString addr.prefixLength}";
    doc = ''
      Expects input in the form of fromString func result
      Returns a CIDR string
    '';
  };

  fromCIDR = {
    __functor = _self:
      with lib; str:
        let
          splits1 = splitString "." str;
          splits2 = flatten (map (x: splitString "/" x) splits1);
          e = i: lib.toInt (builtins.elemAt splits2 i);
        in
        ip (e 0) (e 1) (e 2) (e 3) (e 4);

    doc = ''
      Returns a set of network attributes from a string
      Example:
        fromString "192.168.192.1/24"
      =>
        { a = 192; address = "192.168.192.1"; b = 168; c = 192; d = 1; prefixLength = 24; }
    '';
  };

  network = {
    __functor = _self: addr:
      let
        pfl = addr.prefixLength;
        pow = n: i:
          if i == 1
          then n
          else if i == 0
          then 1
          else n * pow n (i - 1);

        shiftAmount = pow 2 (32 - pfl);
      in
      fromInt ((toInt addr) / shiftAmount * shiftAmount) pfl;

    doc = ''
      Returns network address, given a CIDR
    '';
  };
in
{
  inherit
    fromCIDR
    toCIDR
    toInt
    fromInt
    network
    ;

  fromString = fromCIDR;
}
