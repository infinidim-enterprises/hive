/*
This is a half bothed attempt, what I should really do instead is take the qemu-vm.nix module as example and generate the required xml by myself.
This does contain a lot of useful  goodies!
*/
{lib, ...}: let
  inherit (lib) mkFlake;
  inherit (builtins) toString baseNameOf map attrValues filter;

  xmlTemplate = {args}: let
    inherit (args) config pkgs;
    inherit (pkgs.lib) optionalString elemAt imap0 splitString hasInfix hasSuffix removePrefix removeSuffix toInt last concatStringsSep replaceStrings makeBinPath;

    sName = "${config.system.build.vm}/bin/run-${config.system.name}-vm";
    scriptBuildInputs = with pkgs; [xml2 xmlformat gnugrep gnused];

    startScriptProper = pkgs.writeShellScriptBin "start-local-qemu" ''
      PATH=${makeBinPath scriptBuildInputs}:$PATH
      eval $(nix eval --raw --impure --expr 'with import <nixpkgs> {}; "pathTo_qemu=''${qemu}"')
      pathTo_tmpdir=$(mktemp -d nix-vm-${config.system.name}.XXXXXXXXXX --tmpdir)

      cat ${sName} | sed "s|${config.virtualisation.qemu.package}|$pathTo_qemu|g" > $pathTo_tmpdir/start-vm
      chmod +x $pathTo_tmpdir/start-vm

      $pathTo_tmpdir/start-vm -m 4096M

    '';

    startScript = let
      nonBootDrives = filter (e: !(e.name == "boot")) config.virtualisation.qemu.drives;
      diskCapacity = fname: let
        isRoot = fname == "$NIX_DISK_IMAGE";
        isBoot = hasSuffix ".img" fname;
        isEmpty = hasInfix "empty" fname;
        cleanName =
          if (hasInfix "/" fname && hasSuffix ".qcow2" fname)
          then removePrefix "empty" (removeSuffix ".qcow2" (last (splitString "/" fname)))
          else fname;
      in
        if isRoot
        then toString config.virtualisation.diskSize
        else if isBoot
        then "60"
        else toString (elemAt config.virtualisation.emptyDiskImages (toInt cleanName));
    in
      #
      pkgs.writeShellScriptBin "start-libvirt-vm" ''
        PATH=${makeBinPath scriptBuildInputs}:$PATH
        eval $(nix eval --raw --impure --expr 'with import <nixpkgs> {}; "pathTo_qemu=''${qemu} pathTo_virtiofsd=''${qemu}/libexec/virtiofsd pathTo_virsh=''${libvirt}/bin/virsh pathTo_virtmanager=''${virt-manager}/bin/virt-manager"')
        pathTo_tmpdir=$(mktemp -d nix-vm-${config.system.name}.XXXXXXXXXX --tmpdir)
        _src=$(dirname $(dirname "$0"))

        echo "Slurped variables from runtime: $pathTo_virtiofsd $pathTo_virsh $pathTo_virtmanager"

        CMD="$pathTo_virsh -c qemu:///system"

        mkdir -p $pathTo_tmpdir/xchg
        mkdir -p $pathTo_tmpdir/shared

        _mkDrives() {
          ${concatStringsSep "\n" (imap0 (
            idx: drive: let
              dName = config.system.name + "-disk-" + (toString idx) + ".qcow2";
            in ''
              eval $CMD vol-create-as --pool default --format qcow2 --allocation 0 \
                --name ${dName} \
                --capacity ${diskCapacity drive.file}M
                ${optionalString (drive.deviceExtraOpts ? bootindex) ''
                eval $CMD vol-upload --pool default --vol ${dName} --file $(cat ${sName} | grep 'qcow2 -b ' | awk -F ' ' '{print $6}')
                pathTo_pool=$(dirname $(eval $CMD vol-path --pool default --vol ${dName}))
              ''}
            ''
          )
          config.virtualisation.qemu.drives)}
          echo start
        }

        _mkQemu() {
          cat ${sName} | sed "s|${config.virtualisation.qemu.package}|$pathTo_qemu|g"
        }

        _mkXml() {
          _mkDrives
          cat $_src/resources/xmlStr.txt | \
            grep -v '^[[:space:]]*$' | \
            sed "s|pathTo_virtiofsd|$pathTo_virtiofsd|g" | \
            sed "s|pathTo_tmpdir|$pathTo_tmpdir|g" | \
            sed "s|pathTo_pool|$pathTo_pool|g" | \
            2xml | xmlformat > $pathTo_tmpdir/domain.xml

          echo "mkXml in $pathTo_tmpdir/domain.xml"
        }

        _start() {
          eval $CMD define --file $pathTo_tmpdir/domain.xml
        }

        _stop() {
          eval $CMD vol-delete    --pool default --vol ${config.system.name}.qcow2 || true
          eval $CMD vol-create-as --pool default --format qcow2 --name ${config.system.name}.qcow2 --capacity ${toString config.virtualisation.diskSize}M || true
          echo stopped
        }

        # _mkXml && _start
        _mkQemu
      '';

    driveStr = idx: args: ''
      /domain/devices/disk/@type=file
      /domain/devices/disk/@device=disk
      /domain/devices/disk/driver/@name=qemu
      /domain/devices/disk/driver/@type=qcow2
      /domain/devices/disk/source/@file=pathTo_pool/${config.system.name + "-disk-" + (toString idx)}.qcow2
      /domain/devices/disk/target/@dev=${baseNameOf args.device}
      /domain/devices/disk/target/@bus=virtio
      ${optionalString (args.deviceExtraOpts ? bootindex) "/domain/devices/disk/boot/@order=1"}
    '';

    virtiofsd = {
      source,
      target,
    }: ''
      /domain/devices/filesystem/@type=mount
      /domain/devices/filesystem/@accessmode=passthrough
      /domain/devices/filesystem/driver/@type=virtiofs
      /domain/devices/filesystem/driver/@queue=1024
      /domain/devices/filesystem/binary/@path=pathTo_virtiofsd
      /domain/devices/filesystem/binary/@xattr=on
      /domain/devices/filesystem/source/@dir=${source}
      /domain/devices/filesystem/target/@dir=${target}
      /domain/devices/filesystem/readonly
      /domain/devices/filesystem
    '';

    xmlStr =
      pkgs.writeTextDir "resources/xmlStr.txt"
      ''
        /domain/@type=kvm
        /domain/name=${config.system.name}
        /domain/memory/@unit=MB
        /domain/memory=${toString config.virtualisation.memorySize}
        /domain/currentMemory/@unit=MB
        /domain/currentMemory=${toString config.virtualisation.memorySize}
        /domain/vcpu/@placement=static
        /domain/vcpu=${toString config.virtualisation.cores}

        /domain/os/type/@arch=x86_64
        /domain/os/type/@machine=pc-q35-5.1
        /domain/os/type=hvm

        /domain/os/loader/@readonly=yes
        /domain/os/loader/@type=pflash
        /domain/os/loader=/run/libvirt/nix-ovmf/OVMF_CODE.fd

        /domain/features/acpi
        /domain/features/apic
        /domain/features/vmport/@state=off
        /domain/cpu/@mode=host-model
        /domain/cpu/@check=partial
        /domain/cpu/numa/cell/@id=0
        /domain/cpu/numa/cell/@cpus=0-${toString (config.virtualisation.cores - 1)}
        /domain/cpu/numa/cell/@memory=${toString config.virtualisation.memorySize}
        /domain/cpu/numa/cell/@unit=MB
        /domain/cpu/numa/cell/@memAccess=shared
        /domain/devices/emulator=/run/libvirt/nix-emulators/qemu-system-x86_64

        /domain/devices/filesystem/@type=mount
        /domain/devices/filesystem/@accessmode=passthrough
        /domain/devices/filesystem/driver/@type=virtiofs
        /domain/devices/filesystem/driver/@queue=1024
        /domain/devices/filesystem/binary/@path=pathTo_virtiofsd
        /domain/devices/filesystem/binary/@xattr=on
        /domain/devices/filesystem/source/@dir=/nix/store
        /domain/devices/filesystem/target/@dir=store
        /domain/devices/filesystem/readonly
        /domain/devices/filesystem

        /domain/devices/filesystem/@type=mount
        /domain/devices/filesystem/@accessmode=passthrough
        /domain/devices/filesystem/driver/@type=virtiofs
        /domain/devices/filesystem/driver/@queue=1024
        /domain/devices/filesystem/binary/@path=pathTo_virtiofsd
        /domain/devices/filesystem/binary/@xattr=on
        /domain/devices/filesystem/source/@dir=pathTo_tmpdir/xchg
        /domain/devices/filesystem/target/@dir=xchg
        /domain/devices/filesystem

        /domain/devices/filesystem/@type=mount
        /domain/devices/filesystem/@accessmode=passthrough
        /domain/devices/filesystem/driver/@type=virtiofs
        /domain/devices/filesystem/driver/@queue=1024
        /domain/devices/filesystem/binary/@path=pathTo_virtiofsd
        /domain/devices/filesystem/binary/@xattr=on
        /domain/devices/filesystem/source/@dir=pathTo_tmpdir/shared
        /domain/devices/filesystem/target/@dir=shared

        ${concatStringsSep "/domain/devices/disk\n" (imap0 driveStr config.virtualisation.qemu.drives)}

        /domain/devices/interface/@type=network
        /domain/devices/interface/source/@network=default
        /domain/devices/interface/model/@type=virtio

        /domain/devices/serial/@type=pty
        /domain/devices/serial/target/@type=isa-serial
        /domain/devices/serial/target/@port=0
        /domain/devices/serial/target/model/@name=isa-serial

        /domain/devices/console/@type=pty
        /domain/devices/console/target/@type=serial
        /domain/devices/console/target/@port=0

        /domain/devices/channel/@type=unix
        /domain/devices/channel/target/@type=virtio
        /domain/devices/channel/target/@name=org.qemu.guest_agent.0
        /domain/devices/channel

        /domain/devices/channel/@type=spicevmc
        /domain/devices/channel/target/@type=virtio
        /domain/devices/channel/target/@name=com.redhat.spice.0

        /domain/devices/input/@type=tablet
        /domain/devices/input/@bus=usb
        /domain/devices/input
        /domain/devices/input/@type=mouse
        /domain/devices/input/@bus=ps2
        /domain/devices/input
        /domain/devices/input/@type=keyboard
        /domain/devices/input/@bus=ps2

        /domain/devices/graphics/@type=spice
        /domain/devices/graphics/@autoport=yes
        /domain/devices/graphics/listen/@type=address
        /domain/devices/graphics/image/@compression=off

        /domain/devices/sound/@model=ich9

        /domain/devices/video/model/@type=qxl
        /domain/devices/video/model/@ram=65536
        /domain/devices/video/model/@vram=65536
        /domain/devices/video/model/@vgamem=16384
        /domain/devices/video/model/@heads=1
        /domain/devices/video/model/@primary=yes

        /domain/devices/memballoon/@model=virtio

        /domain/devices/rng/@model=virtio
        /domain/devices/rng/backend/@model=random
        /domain/devices/rng/backend=/dev/urandom
      '';
  in {
    inherit xmlStr startScript startScriptProper;
  };

  builder = {
    mkFlakeArgs,
    config,
    ...
  }: let
    modules = [
      ({modulesPath, ...}: {imports = ["${modulesPath}/virtualisation/qemu-vm.nix"];})
      {virtualisation.useBootLoader = true;}
      ({config, ...}: {
        boot.initrd.kernelModules = ["virtiofs" "overlay"];
        fileSystems."/".autoFormat = true;
        virtualisation.writableStore = false;

        virtualisation.useEFIBoot =
          config.boot.loader.systemd-boot.enable
          || config.boot.loader.efi.canTouchEfiVariables;
      })
      #
      # virtualisation.qemu.drives = [{ file = "$OTHER_CRAP"; }];
      # ({ ... }: { virtualisation.emptyDiskImages = [ 512 128 1024 ]; })
      #
      ({
          config,
          pkgs,
          ...
        } @ args: {
          system.build.libvirtVm =
            pkgs.symlinkJoin
            {
              name = "libvirtVm_" + config.system.name;
              paths = attrValues (xmlTemplate {inherit args;});
              buildInputs = with pkgs; [xml2 xmlformat gnugrep];
              postBuild = ''
                cat $out/resources/xmlStr.txt | grep -v '^[[:space:]]*$' > $out/resources/debug_domain.2xml
                cat $out/resources/xmlStr.txt | grep -v '^[[:space:]]*$' | 2xml | xmlformat > $out/resources/debug_domain.xml
              '';
            };
        })
    ];

    flake = mkFlake (mkFlakeArgs.lib.recursiveMerge
      [
        mkFlakeArgs
        {nixos.hostDefaults = {inherit modules;};}
      ]);
  in
    flake.nixosConfigurations."${config.system.name}".config; #.system.build.libvirtVm; # <- Yo!
in
  builder
