(in-package :vod)

(defun multi-head-p ()
  "Is it a multihead setup?"
  (> (length (slot-value (stumpwm:current-screen) 'stumpwm::heads)) 1))

;; (defvar *group-names* '("emacs"
;;                         "web"
;;                         "main")
;;   "List of group names to be created.")

;; (defvar *frame-preferences* '(("emacs"
;;                                (0 t t :class "Emacs"))
;;                               ("web"
;;                                (0 t t :class "Firefox")
;;                                (1 t t :class "Chromium-browser")
;;                                (2 t t :class "Google-chrome"))
;;                               ("main"
;;                                (0 t t :class ".tilix-wrapped")
;;                                (0 t t :class "Pcmanfm")))
;;   "List of preferences to pass to define-frame-preference.")

(defvar *group-names* '("main")
  "List of group names to be created.")
