{
  virtualization =
    with lib.options;
    with lib.types;
    {
      docker.enable = mkEnableOption "Docker support";
      podman.enable = mkEnableOption "Podman support";
      libvirtd.enable = mkEnableOption "Libvirtd support";
    };

  #   mkOption {
  #   type = types.passwdEntry types.str;
  #   apply = x: assert (builtins.stringLength x < 32 || abort "Username '${x}' is longer than 31 characters which is not allowed!"); x;
  #   description = lib.mdDoc ''
  #     The name of the user account. If undefined, the name of the
  #     attribute set will be used.
  #   '';
  # };
}
