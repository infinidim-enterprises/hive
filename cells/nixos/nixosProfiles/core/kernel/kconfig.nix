{ inputs, cell, ... }:

{
  # TODO: https://github.com/Xe/nixos-configs/blob/master/ops/mai/fs-verity/README.md
  # TODO: https://github.com/NotAShelf/nyx/tree/main/hosts/enyo/kernel/config
  # TODO: https://github.com/cidkidnix/nixos-hypervisor/blob/master/recommended-config/libvirt.nix
  # TODO: aarch64 -  https://github.com/Ramblurr/nixcfg/blob/main/hosts/unstable/aarch64-linux/fairybox/mainline-kernel.nix
  boot.kernelPatches = [
    {
      name = "iotop CONFIG_TASK_DELAY_ACCT";
      patch = null;
      extraConfig = ''
        TASK_DELAY_ACCT y
        TASKSTATS y
      '';
    }

    {
      name = "systemd-nspawn-and-opensnitch";
      patch = null;
      extraConfig = ''
        BPF y
        KPROBES y
        KPROBE_EVENTS y
        BPF_SYSCALL y
        BPF_EVENTS y
        CGROUP_BPF y
      '';
    }

    {
      name = "nfsroot-config";
      patch = null;
      extraConfig = ''
        IP_PNP y
        IP_PNP_DHCP y
        FSCACHE y
        NFS_FS y
        NFS_FSCACHE y
        ROOT_NFS y
        NFS_V4 y
        NFS_V4_2 y
      '';

      # IP_PNP_BOOTP y
      # IP_PNP_RARP y
      # DEVTMPFS y
      # DEVTMPFS_MOUNT y
    }

  ];

}
