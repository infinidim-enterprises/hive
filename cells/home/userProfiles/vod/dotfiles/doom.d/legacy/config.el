;; TODO: set uname/email
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)

(setq-default history-length 1000
              x-stretch-cursor t)

(global-visual-line-mode t)

(let* ((env-default-font (font-spec
                      :family (getenv "HM_FONT_NAME")
                      :size (string-to-number (getenv "HM_FONT_SIZE"))
                      :weight 'normal)))
  (setq doom-font env-default-font
        doom-variable-pitch-font env-default-font
        doom-serif-font env-default-font))

(setq doom-theme 'doom-solarized-dark ;; solarized-dark

      ;; TODO: user-full-name "John Doe"
      ;; TODO: user-mail-address "john@doe.com"

      display-line-numbers-type nil
      create-lockfiles nil
      dired-dwim-target t
      gcmh-high-cons-threshold most-positive-fixnum
      max-specpdl-size 100000
      tab-always-indent 'complete
      company-idle-delay 0.5
      company-minimum-prefix-length 2
      company-transformers nil
      company-show-numbers t
      )

(add-hook 'dired-mode-hook (lambda () (dired-async-mode 1)))

(map! [s-up] #'windmove-up
      [s-down] #'windmove-down
      [s-left] #'windmove-left
      [s-right] #'windmove-right
      "s-=" #'text-scale-increase
      "s--" #'text-scale-decrease
      "s-<return>" #'toggle-frame-fullscreen
      "C-x C-y" #'+default/yank-pop
      "C-x f" #'helm-recentf

      :map prog-mode-map
      :nie "s-." #'helm-semantic-or-imenu
      :nie "s-/" #'comment-or-uncomment-region
      :nie "s-;" #'comment-dwim

      :map helm-find-files-map
      "<left>" #'helm-find-files-up-one-level
      "<right>" #'helm-execute-persistent-action)

(use-package! forge
              :after magit)

(with-eval-after-load 'magit
  (require 'forge))

(use-package! windsize
              :bind (("s-p" . windsize-up)
                     ("s-n" . windsize-down)
                     ("s-b" . windsize-left)
                     ("s-f" . windsize-right))
              :custom
              (windsize-cols 1)
              (windsize-rows 1))

(use-package! lsp-ui
              :commands lsp-ui-mode
              :hook (lsp-mode . lsp-ui-mode))

(use-package! helm-tramp
              :config
              (setq tramp-default-method "sshx")
              (setq make-backup-files nil)
              (setq create-lockfiles nil)
              (setq helm-tramp-custom-connections '(/sshx:admin@frogstar:/home/admin
                                                    )))
(use-package! vlf
              :config
              (require 'vlf-setup)
              (custom-set-variables
               '(vlf-application 'dont-ask)))

(use-package! imenu-list
              :config
              (setq imenu-list-auto-resize t)
              (setq imenu-list-focus-after-activation t)
              (setq imenu-list-after-jump-hook nil)
              (add-hook 'menu-list-after-jump-hook #'recenter-top-bottom)
              )

(use-package! w3m
              :commands (w3m)
              :config
              (setq w3m-use-tab-line nil)
              )

(use-package! ein
              :config
              (setq ob-ein-languages
                    (quote
                     (("ein-python" . python)
                      ("ein-ruby" . ruby))))
              )

(after! ein:ipynb-mode                  ;
        (poly-ein-mode 1)
        (hungry-delete-mode -1))

;; (use-package! undo-fu
;;               :config
;;               ;; Store more undo history to prevent loss of data
;;               (setq undo-limit 400000
;;                     undo-strong-limit 3000000
;;                     undo-outer-limit 3000000)

;;               (define-minor-mode undo-fu-mode
;;                 "Enables `undo-fu' for the current session."
;;                 :keymap (let ((map (make-sparse-keymap)))
;;                           (define-key map [remap undo] #'undo-fu-only-undo)
;;                           (define-key map [remap redo] #'undo-fu-only-redo)
;;                           (define-key map (kbd "C-_")     #'undo-fu-only-undo)
;;                           (define-key map (kbd "M-_")     #'undo-fu-only-redo)
;;                           (define-key map (kbd "C-M-_")   #'undo-fu-only-redo-all)
;;                           (define-key map (kbd "C-x r u") #'undo-fu-session-save)
;;                           (define-key map (kbd "C-x r U") #'undo-fu-session-recover)
;;                           map)
;;                 :init-value nil
;;                 :global t)
;;               )

;; (use-package! color-rg
;;               :commands (color-rg-search-input color-rg-search-symbol
;;                                                color-rg-search-input-in-project
;;                                                )
;;               :bind
;;               (:map isearch-mode-map
;;                     ("M-s M-s" . isearch-toggle-color-rg))
;;               )

(use-package! iscroll
              :config
              (add-hook! 'org-mode-hook 'iscroll-mode)
              )

(use-package! helm-rg)
(use-package! fd-dired)
(use-package! find-dupes-dired)

(use-package! dogears
              :hook (text-mode . dogears-mode)
              :config
              :bind (:map global-map
                          ("M-g d" . dogears-go)
                          ("M-g M-b" . dogears-back)
                          ("M-g M-f" . dogears-forward)
                          ("M-g M-d" . dogears-list)
                          ("M-g M-D" . dogears-sidebar)))

(use-package! session-async)

(add-hook! 'before-save-hook 'font-lock-flush)

;; (use-package! auto-save
;;               :config
;;               (auto-save-enable)
;;               (setq auto-save-silent t)   ; quietly save
;;               ;; after foraml-buffer
;;               (setq auto-save-idle 5)
;;               (setq auto-save-delete-trailing-whitespace t)  ; automatically delete spaces at the end of the line when saving
;;               ;; custom predicates if you don't want auto save.
;;               ;; disable auto save mode when current filetype is an gpg file.
;;               (setq auto-save-disable-predicates
;;                     '((lambda ()
;;                         (string-suffix-p
;;                          "gpg"
;;                          (file-name-extension (buffer-name)) t))))
;;               )

;; i18n
(quail-define-package
 "russian-phonetic" "Cyrillic" "[Русский]" nil
 "ЯЖЕРТЫ Phonetic layout"
 nil t t t t nil nil nil nil nil t)

(quail-define-rules
 ("1" ?1)
 ("2" ?2)
 ("3" ?3)
 ("4" ?4)
 ("5" ?5)
 ("6" ?6)
 ("7" ?7)
 ("8" ?8)
 ("9" ?9)
 ("0" ?0)
 ("-" ?-)
 ("=" ?ь)
 ("`" ?ю)
 ("q" ?я)
 ("w" ?ж)
 ("e" ?е)
 ("r" ?р)
 ("t" ?т)
 ("y" ?ы)
 ("u" ?у)
 ("i" ?и)
 ("o" ?о)
 ("p" ?п)
 ("[" ?ш)
 ("]" ?щ)
 ("a" ?а)
 ("s" ?с)
 ("d" ?д)
 ("f" ?ф)
 ("g" ?г)
 ("h" ?ч)
 ("j" ?й)
 ("k" ?к)
 ("l" ?л)
 (";" ?\;)
 ("'" ?')
 ("\\" ?э)
 ("z" ?з)
 ("x" ?х)
 ("c" ?ц)
 ("v" ?в)
 ("b" ?б)
 ("n" ?н)
 ("m" ?м)
 ("," ?,)
 ("." ?.)
 ("/" ?/)

 ("!" ?!)
 ("@" ?@)
 ("#" ?ё)
 ("$" ?Ё)
 ("%" ?ъ)
 ("^" ?Ъ)
 ("&" ?&)
 ("*" ?*)
 ("(" ?\()
 (")" ?\))
 ("_" ?_)
 ("+" ?Ь)
 ("~" ?Ю)

 ("Q" ?Я)
 ("W" ?Ж)
 ("E" ?Е)
 ("R" ?Р)
 ("T" ?Т)
 ("Y" ?Ы)
 ("U" ?У)
 ("I" ?И)
 ("O" ?О)
 ("P" ?П)
 ("{" ?Ш)
 ("}" ?Щ)
 ("A" ?А)
 ("S" ?С)
 ("D" ?Д)
 ("F" ?Ф)
 ("G" ?Г)
 ("H" ?Ч)
 ("J" ?Й)
 ("K" ?К)
 ("L" ?Л)
 (":" ?:)
 ("\"" ?\")
 ("|" ?Э)
 ("Z" ?З)
 ("X" ?Х)
 ("C" ?Ц)
 ("V" ?В)
 ("B" ?Б)
 ("N" ?Н)
 ("M" ?М)
 ("<" ?<)
 (">" ?>)
 ("?" ??))

(setq default-input-method "russian-phonetic")

;; FIXME: Sly / stumpwm stuff - .fasl files in /nix/store

(use-package! sly
              :init (setq sly-ignore-protocol-mismatches t
                          sly-compile-file-options (list :fasl-directory "/tmp")))

(defun sly-stumpwm-start ()
  (sly-connect "127.0.0.1" 4405)
  (sleep-for 2)
  (when (buffer-live-p (get-buffer "*sly-mrepl for sbcl*"))
    (set-buffer "*sly-mrepl for sbcl*")
    (sly-mrepl--eval-for-repl `(slynk-mrepl:guess-and-set-package "VOD"))))

(defun sly-stumpwm-stop ()
  (sly-disconnect-all)
  (kill-buffer (get-buffer "*sly-mrepl for sbcl*")))
