{ inputs, cell, ... }:
final: prev: {
  nzbget = prev.nzbget.overrideAttrs (_: {
    inherit (final.sources.nzbget) pname version src;
    patches = [ ./nzbget-remove-git-usage.patch ];

    preConfigure = ''
      mkdir -p build/par2-turbo/src
      cp -r ${final.sources.par2cmdline-turbo.src} build/par2-turbo/src/par2-turbo
      chmod -R u+w build/par2-turbo/src/par2-turbo
    '';
  });
}
