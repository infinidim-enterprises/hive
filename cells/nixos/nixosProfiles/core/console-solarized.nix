{ inputs, cell, ... }:

{ pkgs, lib, config, ... }:
let
  inherit (lib) mkDefault mkForce;
  isHidpi = config.deploy.params.hidpi.enable;
  size = if isHidpi then "32" else "16";
in
{
  environment.etc."console-solarized.conf".text = ''
    THEME=dark
  '';
  systemd.services."console-solarized@" = {
    after = [ "getty@%i.service" ];
    serviceConfig = {
      Type = "oneshot";
      StandardOutput = "tty";
      TTYPath = "/dev/%i";
      TTYVTDisallocate = "yes";
      ExecStart = "${pkgs.sources.console-solarized.src}/console-solarized";
    };
  };
  systemd.services."getty@".requires = [ "console-solarized@%i.service" ];
  services.getty.greetingLine = mkForce "[?12l[?25h";
  services.getty.helpLine = mkForce ''<<< \l >>>'';
  console.earlySetup = true; # NOTE: this should make the boot quite?
  console.packages = [ pkgs.powerline-fonts ];
  console.font = mkDefault "ter-powerline-v${size}n";
  console.colors = mkDefault [
    # solarized palette
    "073642" # 0 - black
    "dc322f" # 1 - red
    "859900" # 2 - green
    "b58900" # 3 - yellow
    "268bd2" # 4 - blue
    "d33682" # 5 - magenta
    "2aa198" # 6 - cyan
    "eee8d5" # 7 - white
    "002b36" # 8 - brblack
    "cb4b16" # 9 - brred
    "586e75" # 10 - brgreen
    "657b83" # 11 - bryellow
    "839496" # 12 - brblue
    "6c71c4" # 13 - brmagenta
    "93a1a1" # 14 - brcyan
    "fdf6e3" # 15 - brwhite
  ];
}
