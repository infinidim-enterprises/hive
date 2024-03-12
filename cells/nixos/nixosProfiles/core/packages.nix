{ inputs, cell, ... }:

{ pkgs, ... }:
let
  # NOTE: older nixos had it named differently
  utilLinux = if pkgs ? utillinux then pkgs.utillinux else pkgs.util-linux;
in
{
  environment.systemPackages = with pkgs; [
    smem # mem usage with shared mem

    # Networking
    bridge-utils # An userspace tool to configure linux bridges (deprecated in favour or iproute2)
    iproute2 # A collection of utilities for controlling TCP/IP networking and traffic control in Linux
    nfs-utils # Linux user-space NFS utilities
    iputils # arping, clockdiff, ping, tracepath
    dnsutils # dig
    wget
    curl

    utilLinux # A set of system utilities for Linux
    binutils
    coreutils
    moreutils
    sysfsutils
    utillinux # A set of system utilities for Linux
    file
    lsof
    ncdu

    # hardware
    smartmontools # Tools for monitoring the health of hard drives
    nvme-cli # NVM-Express user space tooling for Linux
    acpi # Show battery status and other ACPI information
    acpitool # A small, convenient command-line ACPI client with a lot of features
    lm_sensors # Tools for reading hardware sensors
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
