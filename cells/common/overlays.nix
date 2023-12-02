{
  inputs,
  cell,
}: {
  common-packages = _: _: cell.packages.misc;
  latest-overrides = _: _: cell.overrides;
  # sources.zsh
}
