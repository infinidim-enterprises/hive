{ inputs, cell, ... }:

{ pkgs, ... }:

{
  boot.binfmt.registrations.jar = {
    recognitionType = "extension";
    magicOrExtension = "jar";
    interpreter = pkgs.writeScript "binfmt-jar" ''
      #!/bin/sh
      exec ${pkgs.openjdk}/bin/java -jar "$@"
    '';
  };
}
