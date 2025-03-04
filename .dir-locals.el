;;; Directory Local Variables
;;; mainly here to set the proper nixd-lsp values

((nil . ((eval . (load (expand-file-name (concat (projectile-acquire-root) ".lsp-nixd.el")))))))
