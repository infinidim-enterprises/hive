(in-package :vod)

;; probably for debugging only
;; (defun show-key-seq (key seq val)
;;   (message (print-key-seq (reverse seq))))
;; (add-hook *key-press-hook* 'show-key-seq)

;; multi key setting
(defun apply-keys-to-map (map key-pairs)
  "apply multi key defines"
  (do ((i 0 (+ i 2)))
      ((= i (length key-pairs)))
    (let ((key (nth i key-pairs))
          (fn (nth (1+ i) key-pairs)))
      (when fn
        (define-key map key fn)))))

(set-prefix-key (kbd "C-'"))

(apply-keys-to-map
 *top-map*
 (list
  (kbd "Menu")                    "rofi-dmenu"

  ;; stumpwm pass-otp
  (kbd "C-s-p")                   "pass-otp"

  ;; desktop switcher
  (kbd "C-M-Right")               "gnext"
  (kbd "C-M-Left")                "gprev"

  ;; navigation
  (kbd "M-Up")                  "move-focus up"
  (kbd "M-Down")                "move-focus down"
  (kbd "M-Right")               "move-focus right"
  (kbd "M-Left")                "move-focus left"

  ;; pushing windows
  (kbd "M-s-Up")                  "move-window up"
  (kbd "M-s-Down")                "move-window down"
  (kbd "M-s-Right")               "move-window right"
  (kbd "M-s-Left")                "move-window left"

  ;; Taking windows to different desktop
  (kbd "C-M-s-Right")             "gnext-with-window"
  (kbd "C-M-s-Left")              "gprev-with-window"

  ;; window switcher
  (kbd "M-TAB")                   "next"
  (kbd "s-TAB")                   "next-in-frame"

  ;; Volume keys
  (kbd "XF86AudioMute")           "exec amixer -c 0 sset Master toggle"
  (kbd "XF86AudioMicMute")        "exec amixer -c 0 sset Capture toggle"
  (kbd "XF86AudioLowerVolume")    "exec amixer -c 0 sset Master 5%-"
  (kbd "XF86AudioRaiseVolume")    "exec amixer -c 0 sset Master 5%+"

  ;; Brightness keys
  (kbd "XF86MonBrightnessDown")   "exec xbacklight -dec 2"
  (kbd "XF86MonBrightnessUp")     "exec xbacklight -inc 2"
  (kbd "s-XF86MonBrightnessDown") "exec xbacklight -set 15"
  (kbd "s-XF86MonBrightnessUp")   "exec xbacklight -set 100"

  ;; Power menu
  (kbd "C-M-Delete")              "cmd-power-menu"
  (kbd "SunPrint_Screen")         "cmd-screenshot-menu"

  ;; show/hide stuff
  ;; (kbd "S-s-Left")                "stumptray"
  (kbd "C-M-Down")                "zz-toggle-mode-line"

  ;; open a new tilix tab
  (kbd "C-S-RET")                 "tilix"
  ;; switch to tilix
  (kbd "C-s-RET")                 "tilix"

  ;; firefox
  (kbd "C-s-b")                   "firefox"

  ;; filemanagers
  (kbd "C-s-f")                   "pcmanfm"

  ;; window ops
  (kbd "C-Menu")                  "global-windowlist"
  (kbd "s-Menu")                  "global-pull-windowlist"
  ))

;;winner-mode
;;(apply-keys-to-map
;; *winner-map*
;; (list
;;  (kbd "Left")                    "winner-undo"
;;  (kbd "Right")                    "winner-redo"))

#||

||#
(apply-keys-to-map
 *root-map*
 (list
  (kbd "C-'")                     "grouplist"

  (kbd "c")                       "gnew"
  (kbd "C-c")                     "gnew-float"
  (kbd "d")                       "gkill"

  (kbd "s-p")                     "pass-otp"
  (kbd "C-s-p")                   "pass-otp-show-all"

  ;; window properties
  ;; (kbd "I")                       "show-window-properties"
  (kbd "I")                       "current-window-info"
  (kbd "L")                       "list-window-properties"
  (kbd "Delete")                  "repack-window-numbers"

  ;; Marking and pulling windows into frame
  (kbd "m")                       "mark"
  (kbd "C-m")                     "clear-window-marks"
  (kbd "p")                       "pull-marked"

  ;; module clipboard-history
  (kbd "C-y")                     "show-clipboard-history"

  ;; commands
  (kbd "C-.")                     "rofi-dmenu"
  (kbd "~")                       "rotate-windows"
  (kbd "|")                       "toggle-split"
  (kbd "e")                       "emacsclient"
  (kbd "C-e")                     "emacs"

  (kbd "t")                       "xterm-tabbed"
  (kbd "C-t")                     "xterm-tabbed"
  (kbd "s-RET")                   (terminal-command "screen")

  ;; (kbd "s-Delete")                "screenshot"

  ;; Notifications
  ;; (kbd "s-a")                     "notifications-add"
  ;; (kbd "s-r")                     "notifications-reset"
  ;; (kbd "s-d")                     "notifications-delete-first"
  ;; (kbd "s-D")                     "notifications-delete-last"
  ;; (kbd "s-s")                     "notifications-show"
  ;; (kbd "s-m")                     "lastmsg"

  ;; remote displays
  ;; (kbd "M-s-k")                   "vnc-xkb-rate"
  ;; (kbd "C-s-l")                   "vnc-screen-clear"
  ;; (kbd "C-s-r")                   "vnc-redshift"

  ;; menus
  (kbd ".")                       "cmd-start-menu"
  (kbd "s-l")                     "cmd-heads-menu"
  (kbd "C-s")                     "rofi-ssh"

  (kbd "C-;")                     "slynk-toggle"

  ;; misc FIXES
  ;; (kbd "C-K")                     "xkb-reset"
  ))

(defun key-seq-msg (key key-seq cmd)
  "Show a message with current incomplete key sequence."
  (declare (ignore key))
  (or (eq *top-map* *resize-map*)
      (stringp cmd)
      (let ((*message-window-gravity* :bottom-left))
        (message "~A" (print-key-seq (reverse key-seq))))))

;; (remove-hook *key-press-hook* 'key-seq-msg)
;; (add-hook *key-press-hook* 'key-seq-msg)
;; (define-key *root-map* (kbd "h-h") (add-hook *key-press-hook* 'key-seq-msg))

;;TODO: self define keymap
;; (defvar *zz-help-map*   (make-sparse-keymap) "Keymap help")
;; (defvar *zz-menu-map*   (make-sparse-keymap) "Keymap menu")

;; *zz-help-map*
;; (apply-keys-to-map
;; *zz-help-map*
;; (list
  ;; (kbd "m")         (format nil "exec xterm -e info ~a"
  ;;                           (merge-pathnames "doc/stumpwm.info" *zz-load-directory*))
  ;; (kbd "C-m")       "exec firefox http://stumpwm.org/manual/stumpwm.html"
  ;; (kbd "s")         "exec firefox http://lxr.free-electrons.com/"
  ;; (kbd "C-s")       "exec firefox http://svnweb.freebsd.org/"
;;  (kbd "v")         "describe-variable"
;;  (kbd "f")         "describe-function"
;;  (kbd "k")         "describe-key"
;;  (kbd "w")         "where-is"
;;  ))

;;
;;(apply-keys-to-map
;; *root-map*
;; (list
  ;; (kbd "s-x")       *zz-x-map*
  ;; (kbd "s-c")       *zz-c-map*
  ;; (kbd "s-e")       *zz-exec-map*
  ;; (kbd "s-w")       *zz-window-map*
  ;; (kbd "s-v")       *zz-view-map*
;;  (kbd "h")       *zz-help-map*
;;  ))

;; *zz-x-map* maybe make it a bit more emacshish?
;; (apply-keys-to-map
;;  *zz-x-map*
;;  (list
;;   (kbd "0")         "remove"
;;   (kbd "1")         "only"
;;   (kbd "2")         "vsplit"
;;   (kbd "3")         "hsplit"
;;   ))
