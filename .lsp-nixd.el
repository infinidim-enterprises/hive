;;; .lsp-nixd.el --- Description -*- lexical-binding: t; -*-

(defun dir-locals/setup-nixd ()
  (when (getenv "PRJ_ROOT")
    (let* ((prj_root (getenv "PRJ_ROOT"))
           (username (getenv "USER"))
           (hostname (with-temp-buffer (call-process "hostname" nil t nil)
                                       (string-trim (buffer-string))))
           (flakeref (format "(builtins.getFlake \"%s\")" prj_root))
           (options-nixos (format "%s.nixosConfigurations.nixos-%s.options" flakeref hostname))
           (options-home-manager (format "%s.homeConfigurations.home-nixd.options" flakeref)))
      (setq lsp-nix-nixd-nixpkgs-expr "import <nixpkgs> { }"
            lsp-nix-nixd-nixos-options-expr options-nixos
            lsp-nix-nixd-home-manager-options-expr options-home-manager))))

(unless (memq 'dir-locals/setup-nixd envrc-mode-hook)
  (add-hook 'envrc-mode-hook #'dir-locals/setup-nixd))
