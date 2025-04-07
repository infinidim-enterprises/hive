{ pkgs, lib, config, ... }:
let
  inherit (lib) mkMerge mkIf genAttrs;
  documents = genAttrs [
    "application/vnd.comicbook-rar"
    "application/vnd.comicbook+zip"
    "application/x-cb7"
    "application/x-cbr"
    "application/x-cbt"
    "application/x-cbz"
    "application/x-ext-cb7"
    "application/x-ext-cbr"
    "application/x-ext-cbt"
    "application/x-ext-cbz"
    "application/x-ext-djv"
    "application/x-ext-djvu"
    "image/vnd.djvu+multipage"
    "application/x-bzdvi"
    "application/x-dvi"
    "application/x-ext-dvi"
    "application/x-gzdvi"
    "application/pdf"
    "application/x-bzpdf"
    "application/x-ext-pdf"
    "application/x-gzpdf"
    "application/x-xzpdf"
    "application/postscript"
    "application/x-bzpostscript"
    "application/x-gzpostscript"
    "application/x-ext-eps"
    "application/x-ext-ps"
    "image/x-bzeps"
    "image/x-eps"
    "image/x-gzeps"
    "image/tiff"
    "application/oxps"
    "application/vnd.ms-xpsdocument"
    "application/illustrator"
  ]
    (_: "org.gnome.Evince.desktop");
in
mkMerge
  [
    (mkIf config.xdg.mimeApps.enable {
      xdg.mimeApps.defaultApplications = documents;
      xdg.mimeApps.associations.added = documents;
    })

    {
      home.packages = with pkgs; [
        # font-manager # Simple font management for GTK desktop environments
        # foliate # A simple and modern GTK eBook reader
        evince # GNOME's document viewer
      ];
    }

    {
      programs.sioyek.enable = true;
      # programs.sioyek.config = {};
      # programs.sioyek.bindings = {};
    }
  ]
