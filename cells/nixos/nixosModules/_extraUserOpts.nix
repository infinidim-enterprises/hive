{
  virtualization =
    with lib.options;
    with lib.types;
    {
      docker.enable = mkEnableOption "Docker support";
      podman.enable = mkEnableOption "Podman support";
      libvirtd.enable = mkEnableOption "Libvirtd support";
    };
}
