;; -*- mode: common-lisp -*-
;;* Nyxt
(in-package #:nyxt-user)

(define-configuration (input-buffer)
  ((default-modes (pushnew 'nyxt/mode/emacs:emacs-mode %slot-value%))))

(defvar *ext-keymap* (make-keymap "custom-map"))

(define-key *ext-keymap*
            "S-space" 'nyxt/mode/hint:follow-hint

            "C-x C-f" 'set-url
            "C-x f" 'set-url-new-buffer

            "C-]" 'switch-buffer-next
            "C-[" 'switch-buffer-previous

            "C-a" 'nyxt/mode/annotate:annotate-highlighted-text

            "M-]" 'nyxt/mode/history:history-forwards
            "M-[" 'nyxt/mode/history:history-backwards)

(define-mode custom-mode
    nil
  "Dummy mode for the custom key bindings in *ext-keymap*."
  ((keyscheme-map
    (nkeymaps/core:make-keyscheme-map nyxt/keyscheme:cua *ext-keymap*
                                      nyxt/keyscheme:emacs *ext-keymap*
                                      nyxt/keyscheme:vi-normal
                                      *ext-keymap*))))

(define-configuration web-buffer
  "Enable this mode by default."
  ((default-modes (pushnew 'custom-mode %slot-value%))))
