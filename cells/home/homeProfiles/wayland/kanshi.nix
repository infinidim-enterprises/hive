{ ... }:

{
  services.kanshi.enable = true;
  services.kanshi.systemdTarget = "graphical-session.target";
}
