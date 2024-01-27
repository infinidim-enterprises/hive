{ inputs, cell, ... }:

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    smem # mem usage with shared mem

    # Networking
    bridge-utils
    nfs-utils
    iputils
    dnsutils # dig
    wget
    curl

    binutils
    coreutils
    moreutils
    sysfsutils
    utillinux # A set of system utilities for Linux
    file
    lsof
    ncdu

    # hardware
    acpi
    acpitool
    lm_sensors
    pciutils # Tools for inspecting and manipulating PCI devices
    usbutils # Tools for working with USB devices, such as lsusb

    ###
    brightnessctl

    vim
    gnused

    # Archive tools
    gzip
    unrar
    unzip
    p7zip

    # filesystems related
    exfat
    dosfstools
    gptfdisk
    parted
  ];
}
