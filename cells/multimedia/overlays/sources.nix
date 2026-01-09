{ inputs, cell, ... }:
final: _: { sources = final.callPackage cell.nvsources.arr.generated { }; }
