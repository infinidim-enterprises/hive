{ lib, ... }:
let
  inherit (lib) mkFlake;
  inherit (builtins) toString baseNameOf map attrValues filter;

  builder =
    { mkFlakeArgs
    , config
    , ...
    }:
    let
      modules = [
        ({ modulesPath
         , config
         , pkgs
         , lib
         , ...
         }: {
          imports = [ "${modulesPath}/virtualisation/qemu-vm.nix" ];
          # virtualisation.emptyDiskImages = [ 512 128 1024 ];
          # virtualisation.qemu.networkingOptions
          virtualisation.diskSize = 20480; #MB
          virtualisation.memorySize = 8192; #MB
          virtualisation.cores = 4;
          system.build.vmLocalQemu = pkgs.writeShellScriptBin "start-local-qemu" ''
            PATH="${lib.makeBinPath (with pkgs; [xml2 xmlformat gnugrep gnused])}:$PATH"
            eval $(nix eval --raw --impure --expr 'with import <nixpkgs> {}; "pathTo_qemu=''${qemu}"')
            pathTo_tmpdir=$(mktemp -d nix-vm-${config.system.name}.XXXXXXXXXX --tmpdir=$HOME/tmp)
            cat ${config.system.build.vm}/bin/run-${config.system.name}-vm | sed "s|${config.virtualisation.qemu.package}|$pathTo_qemu|g" > $pathTo_tmpdir/start-vm
            chmod +x $pathTo_tmpdir/start-vm

            export NIX_DISK_IMAGE="$pathTo_tmpdir/${config.system.name}.qcow2"
            $pathTo_tmpdir/start-vm
            echo "rm -rf $pathTo_tmpdir"
          '';
        })
      ];

      flake = mkFlake (mkFlakeArgs.lib.recursiveMerge
        [
          mkFlakeArgs
          { nixos.hostDefaults = { inherit modules; }; }
        ]);
    in
    flake.nixosConfigurations."${config.system.name}".config.system.build.vmLocalQemu;
in
builder
