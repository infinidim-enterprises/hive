{ pkgs, text }:

let
  db_check = pkgs.writeShellApplication {
    name = "dbcheck";
    runtimeInputs = with pkgs; [
      gnugrep
      postgresql
      libressl.nc
    ];
    inherit text;
  };
in
db_check
