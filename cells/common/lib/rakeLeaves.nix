{ lib, ... }:
let
  inherit (lib // builtins)
    hasSuffix
    removeSuffix
    filterAttrs
    mapAttrs'
    pathExists
    readDir;

  rakeLeaves = {
    __functor = _self: dirPath:
      let
        seive = file: type:
          (type == "regular" && hasSuffix ".nix" file) || (type == "directory");

        collect = file: type: {
          name = removeSuffix ".nix" file;
          value =
            let path = dirPath + "/${file}"; in
            if
              (type == "regular") ||
              (type == "directory" && pathExists (path + "/default.nix"))
            then path
            else rakeLeaves path;
        };

        files = filterAttrs seive (readDir dirPath);
      in
      filterAttrs (n: v: v != { }) (mapAttrs' collect files);
    doc = ''
      Synopsis: rakeLeaves _path_

      Recursively collect the nix files of _path_ into attrs.

      Output Format:
      An attribute set where all `.nix` files and directories with `default.nix` in them
      are mapped to keys that are either the file with .nix stripped or the folder name.
      All other directories are recursed further into nested attribute sets with the same format.

      Example file structure:
        ./core/default.nix
        ./base.nix
        ./main/dev.nix
        ./main/os/default.nix
      =>
        { core = ./core; base = base.nix; main = { dev = ./main/dev.nix; os =./main/os; }; }
    '';
  };
in
rakeLeaves
