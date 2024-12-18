{ config, lib, pkgs, ... }:
let
  inherit (lib // builtins)
    genAttrs
    mkMerge
    mkIf
    map;

  archives = genAttrs
    (map (e: "application/${e}") [
      "vnd.debian.binary-package"
      "vnd.ms-cab-compressed"
      "vnd.oasis.opendocument.presentation"
      "vnd.oasis.opendocument.spreadsheet"
      "vnd.oasis.opendocument.text"
      "vnd.oasis.opendocument.presentation-template"
      "vnd.oasis.opendocument.spreadsheet-template"
      "vnd.oasis.opendocument.text-template"
      "epub+zip"
      "x-7z-compressed"
      "x-7z-compressed-tar"
      "x-ace"
      "x-alz"
      "x-arc"
      "x-archive"
      "x-arj"
      "x-brotli"
      "x-brotli-compressed-tar"
      "x-bzip"
      "x-bzip-compressed-tar"
      "x-bzip1"
      "x-bzip1-compressed-tar"
      "x-cbr"
      "x-cbz"
      "x-cd-image"
      "x-compress"
      "x-compressed-tar"
      "x-cpio"
      "x-ear"
      "x-gzip"
      "x-java-archive"
      "x-lzh-compressed"
      "x-lrzip"
      "x-lrzip-compressed-tar"
      "x-lzip"
      "x-lzip-compressed-tar"
      "x-lzma"
      "x-lzma-compressed-tar"
      "x-lzop"
      "x-lzop-compressed-tar"
      "x-ms-dos-executable"
      "x-ms-wim"
      "x-rar"
      "x-rpm"
      "x-rzip"
      "x-stuffit"
      "x-tar"
      "x-tarz"
      "x-war"
      "x-xz"
      "x-xz-compressed-tar"
      "x-zoo"
      "zstd"
      "x-zstd"
      "x-zstd-compressed-tar"
      "zip"
    ])
    (_: "engrampa.desktop");
in
mkMerge [
  {
    home.packages = with pkgs; [
      mate.engrampa

      arj
      btar
      gnutar
      gzip
      cpio
      bzip2
      bzip3
      zstd
      xz
      lzo
      lzop
    ];
  }

  (mkIf config.xdg.mimeApps.enable {
    xdg.mimeApps.defaultApplications = archives;
    # xdg.mimeApps.associations.added = archives;
  })

]
