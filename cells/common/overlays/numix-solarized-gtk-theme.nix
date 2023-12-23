{
  inputs,
  cell,
  ...
}: final: prev: {
  numix-solarized-gtk-theme = prev.numix-solarized-gtk-theme.overrideAttrs (_: {
    inherit
      (final.sources.numix-solarized-gtk-theme-git)
      src
      version
      ;
  });
}
