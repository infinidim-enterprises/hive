;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; lang/nix/doctor.el

(unless (executable-find "nix")
  (warn! "Couldn't find the nix package manager. nix-mode won't work."))

(unless (executable-find "nixpkgs-fmt")
  (warn! "Couldn't find nixpkgs-fmt. nix-format-buffer won't work."))
