{ inputs, cell, ... }:

{
  boot = {
    kernelParams = [
      "intel_iommu=on"
      "amd_iommu=on"
    ];
    kernelModules = [ "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" "irqbypass" "virtio" ];
    # PCI id's of graphics card
    # extraModprobeConfig = ''
    #   options vfio-pci ids=10de:1b80,10de:10f0
    # '';
  };

  # TODO: remake with systemd-networkd!
  networking.interfaces.tap0 = {
    virtualOwner = "vod";
    virtual = true;
    virtualType = "tap";
    useDHCP = true;
  };
  environment.etc."qemu/bridge.conf".text = "allow br0";
}
