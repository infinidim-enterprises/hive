{
  desktop = { disks ? [ "/dev/nvme0" "/dev/nvme1" "/dev/nvme2" ], ... }: {
    disk.nvme0 = {
      type = "disk";
      device = builtins.elemAt disks 0;
      content.type = "table";
      content.format = "gpt";
      content.partitions = [

        {
          name = "boot";
          start = "0";
          end = "1M";
          part-type = "primary";
          flags = [ "bios_grub" ];
        }

        {
          name = "ESP";
          start = "1MiB";
          end = "3GiB";
          bootable = true;
          content = {
            type = "mdraid";
            name = "boot";
          };
        }

        {
          name = "zfs";
          start = "3Gib";
          end = "100%";
          content = {
            type = "zfs";
            pool = "zroot";
          };
        }

        # {
        #   name = "mdadm";
        #   start = "3Gib";
        #   end = "100%";
        #   content = {
        #     type = "mdraid";
        #     name = "raid1";
        #   };
        # }

      ];
    };

    disk.nvme1 = {
      type = "disk";
      device = builtins.elemAt disks 1;
      content.type = "table";
      content.format = "gpt";
      content.partitions = [
        {
          name = "boot";
          start = "0";
          end = "1M";
          part-type = "primary";
          flags = [ "bios_grub" ];
        }

        {
          name = "ESP";
          start = "1MiB";
          end = "3GiB";
          bootable = true;
          content = {
            type = "mdraid";
            name = "boot";
          };
        }

        {
          name = "zfs";
          start = "3Gib";
          end = "100%";
          content = {
            type = "zfs";
            pool = "zroot";
          };
        }

      ];

    };

    disk.nvme2 = {
      type = "disk";
      device = builtins.elemAt disks 2;
      content.type = "table";
      content.format = "gpt";
      content.partitions = [
        {
          name = "boot";
          start = "0";
          end = "1M";
          part-type = "primary";
          flags = [ "bios_grub" ];
        }

        {
          name = "ESP";
          start = "1MiB";
          end = "3GiB";
          bootable = true;
          content = {
            type = "mdraid";
            name = "boot";
          };
        }

        {
          name = "zfs";
          start = "3Gib";
          end = "100%";
          content = {
            type = "zfs";
            pool = "zroot";
          };
        }
      ];

    };

    # https://github.com/nix-community/disko/pull/78
    # https://github.com/NixOS/nixpkgs/issues/212762
    # https://github.com/nix-community/disko/issues/114
    # https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/Root%20on%20ZFS.html
    zpool = {
      zroot = {
        type = "zpool";
        mode = "raidz";
        rootFsOptions = {
          compression = "lz4";
          "com.sun:auto-snapshot" = "false";
        };
        mountpoint = "/";
        postCreateHook = "zfs snapshot zroot@blank";

        datasets = {
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
            options.mountpoint = "legacy";
            options."com.sun:auto-snapshot" = "true";
          };

          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
          };

          persist = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options.mountpoint = "legacy";
          };
        };
      };
    };

    mdadm = {
      boot = {
        type = "mdadm";
        level = 1;
        metadata = "1.0";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
        };
      };
    };

  };

  libvirtd = { disks ? [ "/dev/vda" "/dev/vdb" "/dev/vdc" ], lib, ... }:
    let
      inherit (lib) listToAttrs nameValuePair removePrefix;
      disk = listToAttrs (map
        (device: nameValuePair (removePrefix "/dev/" device) {
          inherit device;
          type = "disk";
          content.type = "table";
          content.format = "gpt";
          content.partitions = [

            {
              name = "ESP";
              start = "1MiB";
              end = "3GiB";
              bootable = true;
              content = {
                type = "mdraid";
                name = "boot";
              };
            }

            {
              name = "swap";
              start = "3GiB";
              end = "5GiB";
              bootable = true;
              content = {
                type = "mdraid";
                name = "swap";
              };
            }

            {
              name = "zfs";
              start = "5GiB";
              end = "100%";
              content = {
                type = "zfs";
                pool = "local";
              };
            }
          ];

        })
        disks);
    in
    {
      inherit disk;

      zpool = {
        local = {
          type = "zpool";
          mode = "raidz";
          rootFsOptions = { compression = "lz4"; };

          datasets = {
            root = {
              type = "zfs_fs";
              mountpoint = "/";
              options.mountpoint = "legacy";
              postCreateHook = "zfs snapshot local/root@blank";
            };

            home = {
              type = "zfs_fs";
              mountpoint = "/home";
              options.mountpoint = "legacy";
              options."com.sun:auto-snapshot" = "true";
            };

            nix = {
              type = "zfs_fs";
              mountpoint = "/nix";
              options.mountpoint = "legacy";
            };

            persist = {
              type = "zfs_fs";
              mountpoint = "/persist";
              options.mountpoint = "legacy";
            };

            reserved = {
              type = "zfs_fs";
              options.mountpoint = "none";
              options.refreservation = "1G";
            };
          };
        };
      };

      mdadm = {
        boot = {
          type = "mdadm";
          level = 1;
          metadata = "1.0";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };

        swap = {
          type = "mdadm";
          level = 0;
          metadata = "1.2";
          content = {
            type = "swap";
            randomEncryption = true;
          };
        };

        # swap = {
        #   type = "mdadm";
        #   level = 0;
        #   metadata = "1.2";
        #   content = {
        #     type = "table";
        #     format = "gpt";
        #     partitions = [
        #       {
        #         name = "swap";
        #         type = "partition";
        #         start = "-1G";
        #         end = "100%";
        #         part-type = "primary";
        #         content = {
        #           type = "swap";
        #           randomEncryption = true;
        #         };
        #       }
        #     ];
        #   };
        # };

      };

    };

  oglaroon = { disks ? [ "/dev/disk/by-id/nvme-CT1000P2SSD8_2228E648DC10" ], lib, ... }:
    let
      inherit (lib) listToAttrs nameValuePair removePrefix;
      disk = listToAttrs (map
        (device: nameValuePair (removePrefix "/dev/disk/by-id/" device) {
          inherit device;
          type = "disk";
          content.type = "gpt";
          content.partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
          };

        })
        disks);
    in
    {
      inherit disk;

      zpool = {
        rpool = {
          type = "zpool";
          rootFsOptions = {
            compression = "lz4";
            mountpoint = "none";
            acltype = "posixacl";
            xattr = "sa";
          };

          datasets = {
            root = {
              type = "zfs_fs";
              mountpoint = "/";
              options.mountpoint = "legacy";
              postCreateHook = "zfs snapshot rpool/root@blank";
            };

            nix = {
              type = "zfs_fs";
              mountpoint = "/nix";
              options.mountpoint = "legacy";
            };

            home = {
              type = "zfs_fs";
              mountpoint = "/home";
              options.mountpoint = "legacy";
              options."com.sun:auto-snapshot" = "true";
            };

            persist = {
              type = "zfs_fs";
              mountpoint = "/persist";
              options.mountpoint = "legacy";
            };

            reserved = {
              type = "zfs_fs";
              options.mountpoint = "none";
              options.refreservation = "1G";
            };
          };
        };
      };
    };

  asbleg = { disks ? [ "/dev/disk/by-id/ata-BIWIN_SSD_2051028801186" ], lib, ... }:
    let
      zpool = {
        rpool = {
          type = "zpool";
          rootFsOptions = {
            compression = "lz4";
            mountpoint = "none";
            acltype = "posixacl";
            xattr = "sa";
          };

          datasets = {
            root = {
              type = "zfs_fs";
              mountpoint = "/";
              options.mountpoint = "legacy";
              postCreateHook = "zfs snapshot rpool/root@blank";
            };

            nix = {
              type = "zfs_fs";
              mountpoint = "/nix";
              options.mountpoint = "legacy";
            };

            home = {
              type = "zfs_fs";
              mountpoint = "/home";
              options.mountpoint = "legacy";
              options."com.sun:auto-snapshot" = "true";
            };

            persist = {
              type = "zfs_fs";
              mountpoint = "/persist";
              options.mountpoint = "legacy";
            };

            reserved = {
              type = "zfs_fs";
              options.mountpoint = "none";
              options.refreservation = "1G";
            };
          };
        };
      };

      settings = {
        bypassWorkqueues = true;
        allowDiscards = false;
        fallbackToPassword = true;
        # preLVM = true;
        # NOTE: https://github.com/sgillespie/nixos-yubikey-luks
        # gpgCard = {
        #   gracePeriod = 25;
        #   encryptedPass = "/boot/luks/decryption-key.gpg";
        #   publicKey = "/boot/luks/public-key.asc";
        # };
      };

      inherit (lib) listToAttrs nameValuePair removePrefix;
      disk = listToAttrs (map
        (device: nameValuePair (removePrefix "/dev/disk/by-id/" device) {
          inherit device;
          type = "disk";
          content.type = "gpt";
          content.partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            encryptedSwap = {
              size = "8G";
              content = {
                type = "luks";
                name = "cryptoswap";
                inherit settings;
                content = {
                  type = "swap";
                  resumeDevice = true;
                };
              };
            };

            encryptedRoot = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptoroot";
                inherit settings;
                content = {
                  type = "zfs";
                  pool = "rpool";
                };
              };
            };
          };

        })
        disks);
    in
    { inherit disk zpool; };

  folfanga = { disks ? [ "/dev/disk/by-id/mmc-DF4064_0x33157f7a" ], lib, ... }:
    let
      inherit (lib) listToAttrs nameValuePair removePrefix;
      disk = listToAttrs (map
        (device: nameValuePair (removePrefix "/dev/" device) {
          inherit device;
          type = "disk";
          content.type = "table";
          content.format = "gpt";
          content.partitions = [

            # https://askubuntu.com/questions/500359/efi-boot-partition-and-biosgrub-partition
            # NOTE: only required on BIOS boot with gpt table
            # {
            #   name = "boot";
            #   start = "0";
            #   end = "1M";
            #   part-type = "primary";
            #   flags = [ "bios_grub" ];
            # }

            {
              name = "ESP";
              start = "1MiB";
              end = "1GiB";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            }

            {
              name = "zfs";
              start = "1GiB";
              end = "100%";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            }
          ];

        })
        disks);
    in
    {
      inherit disk;

      zpool = {
        rpool = {
          type = "zpool";
          rootFsOptions = { compression = "lz4"; };

          datasets = {
            "local/root" = {
              type = "zfs_fs";
              mountpoint = "/";
              options.mountpoint = "legacy";
              postCreateHook = "zfs snapshot rpool/local/root@blank";
            };

            "local/nix" = {
              type = "zfs_fs";
              mountpoint = "/nix";
              options.mountpoint = "legacy";
            };

            "persist/home" = {
              type = "zfs_fs";
              mountpoint = "/home";
              options.mountpoint = "legacy";
              options."com.sun:auto-snapshot" = "true";
            };

            "persist/misc" = {
              type = "zfs_fs";
              mountpoint = "/persist";
              options.mountpoint = "legacy";
            };

            reserved = {
              type = "zfs_fs";
              options.mountpoint = "none";
              options.refreservation = "1G";
            };
          };
        };
      };
    };

  folfanga-1 = { disks ? [ "/dev/disk/by-id/mmc-DF4064_0x96bc913c" ], lib, ... }:
    let
      inherit (lib) listToAttrs nameValuePair removePrefix;
      disk = listToAttrs (map
        (device: nameValuePair (removePrefix "/dev/" device) {
          inherit device;
          type = "disk";
          content.type = "table";
          content.format = "gpt";
          content.partitions = [

            {
              name = "ESP";
              start = "1MiB";
              end = "512MiB";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            }

            {
              name = "root";
              start = "1GiB";
              end = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            }
          ];

        })
        disks);
    in
    { inherit disk; };

  folfanga-2 = { disks ? [ "/dev/disk/by-id/mmc-DF4064_0x0e0847ba" ], lib, ... }:
    let
      inherit (lib) listToAttrs nameValuePair removePrefix;
      disk = listToAttrs (map
        (device: nameValuePair (removePrefix "/dev/" device) {
          inherit device;
          type = "disk";
          content.type = "table";
          content.format = "gpt";
          content.partitions = [

            {
              name = "ESP";
              start = "1MiB";
              end = "512MiB";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            }

            {
              name = "root";
              start = "1GiB";
              end = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            }
          ];

        })
        disks);
    in
    { inherit disk; };


  marauder = { disks ? [ "/dev/disk/by-id/usb-Lexar_microSD_RDR_000000000001-0:0" ], lib, ... }:
    let
      inherit (lib) listToAttrs nameValuePair removePrefix;
      disk = listToAttrs (map
        (device: nameValuePair (removePrefix "/dev/disk/by-id/" device) {
          inherit device;
          type = "disk";
          content.type = "gpt";
          content.partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };

            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };

        })
        disks);
    in
    { inherit disk; };

}
