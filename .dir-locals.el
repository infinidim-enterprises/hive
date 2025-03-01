;;; Directory Local Variables
;;; mainly here to set the proper nixd-lsp values


;; (defun dir-locals/setup-nixd ()
;;   (when (getenv "PRJ_ROOT")
;;     (let* ((prj_root (getenv "PRJ_ROOT"))
;;            (username (getenv "USER"))
;;            (hostname (with-temp-buffer (call-process "hostname" nil t nil)
;;                                        (string-trim (buffer-string))))
;;            (flakeref (format "(builtins.getFlake \"%s\")" prj_root))
;;            (options-nixos (format "%s.nixosConfigurations.nixos-%s.options" flakeref hostname))
;;            (options-home-manager (format "%s.homeConfigurations.home-nixd.options" flakeref)))
;;       (setq lsp-nix-nixd-nixpkgs-expr "import <nixpkgs> { }"
;;             lsp-nix-nixd-nixos-options-expr options-nixos
;;             lsp-nix-nixd-home-manager-options-expr options-home-manager))))
;; (add-hook 'envrc-mode-hook #'dir-locals/setup-nixd)
;; .dir-locals.el

((nil . ((eval . (load (expand-file-name ".lsp-nixd.el" default-directory))))))

;; ((nil . ((when (getenv "PRJ_ROOT")
;;            (let* ((prj_root (getenv "PRJ_ROOT"))
;;                   (username (getenv "USER"))
;;                   (hostname (with-temp-buffer (call-process "hostname" nil t nil)
;;                                               (string-trim (buffer-string))))
;;                   (flakeref (format "(builtins.getFlake \"%s\")" prj_root))
;;                   (options-nixos (format "%s.nixosConfigurations.nixos-%s.options" flakeref hostname))
;;                   (options-home-manager (format "%s.homeConfigurations.home-nixd.options" flakeref)))
;;              (setq lsp-nix-nixd-nixpkgs-expr "import <nixpkgs> { }"
;;                    lsp-nix-nixd-nixos-options-expr options-nixos
;;                    lsp-nix-nixd-home-manager-options-expr options-home-manager)))

;;          (indent-tabs-mode . t)
;;          (tab-width . 4)))

;; ((nil . (add-hook 'envrc-mode-hook #'dir-locals/setup-nixd)))
