{ inputs
, cell
, ...
}: final: prev: {
  masterpdfeditor = prev.masterpdfeditor.overrideAttrs (old: {
    inherit (final.sources.masterpdfeditor) pname version src;
    buildInputs = old.buildInputs ++ [ inputs.nixpkgs.pkcs11helper ];
    preInstallPhases = [ "rename_license_file" ];
    rename_license_file = ''
      mv license_en.txt license.txt
    '';
  });
}
