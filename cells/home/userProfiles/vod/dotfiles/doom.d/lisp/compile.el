;;; compile.el --- description -*- lexical-binding: t; -*-
(require 'org)
;; (setq njk/tangle-dir (org-entry-get nil "dest" t))
(setq byte-compile-warnings '(not free-vars unresolved noruntime lexical make-local))

(setq njk/tangle-dir (concat (getenv "DOOMDIR") "/"))

(defun njk/org-babel-tangle-rename ()
  (let ((tangledir njk/tangle-dir)
        (tanglefile (buffer-file-name)))
    (rename-file tanglefile tangledir t)))

(add-hook 'org-babel-post-tangle-hook #'njk/org-babel-tangle-rename)

(org-babel-tangle-file "config.org")
