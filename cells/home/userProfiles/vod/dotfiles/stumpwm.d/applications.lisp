(in-package :vod)
(require :str)

(defun string-escape (str)
  "Escape a string"
  (format nil "~S" str))

(defun named-terminal-title (name)
  "Title for named terminal"
  (format nil "tmux - ~A" name))

(defun probe-file-env-paths (name)
  "Probe file across paths in $PATH.  Returns first pathname found or nil."
  (loop for path in (str:split ":" (uiop:getenv "PATH") :omit-nulls t)
          thereis (probe-file (merge-pathnames name (make-pathname :directory path)))))

(defun close-all-apps ()
  "Closes all windows managed by stumpwm gracefully"
  (let ((win-index-text (run-shell-command "wmctrl -l | awk '{print $1}'" t)))
    (dolist (window (cl-ppcre:split "\\\n" win-index-text))
      (run-shell-command (format nil "wmctrl -i -c ~A" window)))))

(defun logout-start ()
  (echo-string (current-screen) "Ending Session...")
  (close-all-apps)
  (run-hook *quit-hook*))

;; TODO: proper handling of all stuff!
(defcommand system-logout () ()
  (logout-start)
  (run-shell-command
   (format nil "loginctl terminate-session ~A" (getenv "XDG_SESSION_ID")))
  (quit))

(defcommand system-reboot () ()
  (logout-start)
  (run-shell-command "sudo systemctl reboot"))

(defcommand system-shutdown () ()
  (logout-start)
  (run-shell-command "sudo systemctl poweroff"))

(defcommand dmenu () ()
  "Run j4-dmenu"
  ;; FIXME: fonts are set via central location, use it!
  (run-shell-command "exec j4-dmenu-desktop --use-xdg-de --dmenu=\"dmenu -i -b -fn 'UbuntuMono Nerd Font Mono:pixelsize=28' -nb '#002b36' -nf '#839496' -sb '#002b36'\""))

(defcommand passmenu () ()
  "Run j4-dmenu"
  (run-shell-command "exec passmenu --type -l 10 -i -b -fn 'UbuntuMono Nerd Font Mono:pixelsize=28' -nb '#002b36' -nf '#839496' -sb '#002b36'"))

;; TODO: use rufus instead of the above
(defcommand rofi-dmenu () ()
  "Run j4-dmenu with rofi"
  (run-shell-command "exec rofi -modi window,run,ssh,drun -show drun"))

(defcommand rofi-ssh () ()
  "Run rofi-ssh"
  (run-shell-command "exec rofi -modi window,run,ssh,drun -show ssh -show-icons -no-parse-known-hosts -parse-hosts"))

(defcommand rofi-pass () ()
  "Run rofi-pass"
  (run-shell-command "exec rofi-pass"))

(defcommand rofi-systemd () ()
  "Run rofi-systemd"
  (run-shell-command "exec rofi-systemd"))


(defcommand cmd-screenshot-menu () ()
  (show-a-menu *menu-screenshot*))

(defcommand cmd-power-menu () ()
  (show-a-menu *menu-power*))

(defcommand cmd-heads-menu () ()
  (show-a-menu *menu-heads*))

(defcommand cmd-start-menu () ()
  (show-a-menu *menu-start*))

(defcommand toggle-split () ()
  (let* ((group (current-group))
         (cur-frame (tile-group-current-frame group))
         (frames (group-frames group)))
    (if (eq (length frames) 2)
        (progn (if (or (neighbour :left cur-frame frames)
                       (neighbour :right cur-frame frames))
                   (progn
                     (only)
                     (vsplit))
                   (progn
                     (only)
                     (hsplit))))
        (message "Works only with 2 frames"))))

(defcommand conky () ()
  "Conky with proper fonts"
  (run-shell-command "conky"))
;; -f 'UbuntuMono Nerd Font Mono:pixelsize=28'

(defcommand dmtool () ()
  "LightDM dm-tool switch-to-greeter"
  (run-shell-command "dm-tool switch-to-greeter"))

;; emacs handling
(defcommand emacsclient () ()
  "Run emacsclient with a new frame"
  (run-shell-command "emacsclient -c -n"))

(defcommand emacsinstance () ()
  "Run emacsclient with a new frame"
  (run-shell-command "emacs"))

(defcommand xterm-abbed () ()
  "tabbed Xterm"
  (run-shell-command "tabbed -t '#002b36' -u '#002b36' -c xterm -u8 -into"))

(defcommand reinit () ()
  "docstring"
  (run-commands "reload" "loadrc"))

(defcommand scrot-screenshot () ()
  (message "-= screenshot =-")
  (run-shell-command "exec scrot -d 5 '%d.%m.%Y_$wx$h_%H:%M:%S.jpg' -e 'mv $f ~/Pictures/screenshots'"))

(defcommand screenrecord () ()
  (message "-= screenrecord =-")
  (run-shell-command "exec byzanz-record -d 60 ~/Pictures/screenshots/$(date +\"%Y-%m-%d_%H:%M:%S\").gif"))

(defcommand zulucrypt () ()
  (run-shell-command "gtk-launch zuluCrypt"))

(defcommand zz-toggle-mode-line () ()
  "Toggle the mode line in StumpWM."
  (toggle-mode-line (current-screen) (current-head)))

(defcommand dia () ()
  "Run Dia --integrated --nosplash"
  (run-shell-command "dia --integrated --nosplash"))

;; TODO: proper quit command, mainly, find all windows and send 'soft' close, before quitting
(defcommand close-windows-quit-session () ()
  "Close all windows and quit session"
  (run-shell-command (format nil "loginctl terminate-session ~A" (getenv "XDG_SESSION_ID"))))

;; run-or-raise
(def-run-or-raise-command emacs '(:class "Emacs"))
(def-run-or-raise-command tilix '(:class ".tilix-wrapped"))
(def-run-or-raise-command firefox '(:class "Firefox"))
(def-run-or-raise-command pcmanfm '(:class "Pcmanfm"))

(defcommand current-window-info () ()
  "Shows the properties of the current window. These properties can be
used for matching windows with run-or-raise or window placement
-merules."
  (let ((w (current-window))
        (*suppress-echo-timeout* t)
        (nl (string #\NewLine)))
    (echo-string (current-screen)
                 (concat "class:    " (window-class w) nl
                         "instance: " (window-res w) nl
                         "type:     " (string (window-type w)) nl
                         "role:     " (window-role w) nl
                         "title:    " (window-title w) nl
                         "width:    " (format nil "~a" (window-width w)) nl
                         "height    " (format nil "~a" (window-height w))))))

(defcommand set-backlight-directly (level) ((:number "Set brightness level:"))
  (with-open-file (sys-backlight-file "/sys/class/backlight/intel_backlight/brightness"
                                      :direction :output :if-exists :overwrite)
    (format sys-backlight-file "~a~%" level)))

(defcommand loadrc-forget () ()
  "Reload the @file{~/.stumpwmrc} file without remembering current state."
  (handler-case
      (progn
        (with-restarts-menu (load-rc-file nil)))
    (error (c)
      (message "^B^1*Error loading rc file:^n ~A" c))
    (:no-error (&rest args)
      (declare (ignore args))
      (message "rc file loaded successfully."))))

;;;;;;;

;; (defcommand xbacklight (args) ((:shell "Arguments: "))
;;   "Run xbacklight"
;;   (run-shell-command (format nil "xbacklight ~S" args)))

;; (defcommand amixer (args) ((:shell "Arguments: "))
;;   "Run amixer"
;;   (run-shell-command (format nil "amixer ~A" args)))

(defcommand lock () ()
  "Lock session"
  (run-shell-command "dm-tool lock"))

(defapp run-firefox () () ("Browser")
  "Run Firefox"
  (run-or-raise "firefox" '(:class "Firefox")))

(defapp run-named-terminal (name) ((:string "Name: ")) ("Terminal")
  "Run terminal"
  (let* ((title (named-terminal-title name))
         (args (list
                "st"
                "-t" title ;; Title
                "-f" "Source Code Pro"
                "-e" "/usr/bin/tmux" "new-session" "-AD" "-s" name))
         (cmd (str:join " " (map 'list #'string-escape args))))
    (run-or-raise cmd `(:title ,title))))

(defapp run-chrome () () ("Browser (Chrome)")
  "Run Chrome"
  (run-or-raise "firejail google-chrome-stable" '(:class "Google-chrome")))

(defapp run-thunderbird () () ("Email")
  "Run Thunderbird"
  (let ((path (loop for file in '("thunderbird-bin" "thunderbird")
                      thereis (probe-file-env-paths file))))
    (when path
      (run-or-raise (namestring path) '(:class "Thunderbird")))))

;; (stumpwm:screen-groups)
;;(describe stumpwm:current-head)
;; (defcommand notifications-reset () ()
;;    "Desktop notifications Reset"
;;  (desktop-notifications:reset))

;; (defapp run-keepassxc () () ("Passwords")
;;   "Run KeepassXC"
;;   (run-or-raise "keepassxc" '(:class "keepassxc")))

;; (defutil toggle-touchpad () () ("Toggle touchpad")
;;   "Enable/Disable touchpad"
;;   (run-shell-command "toggle-touchpad"))

#||
(flet ((emacs-daemon-running-p ()
         "Determine if emacs daemon running."
         (when-let ((output (run-shell-command "emacsclient --eval t" t)))
           (string= "t" (str:trim output))))
       (emacs-name-plist (name)
         (let* ((title (format nil "Emacs - ~A" name))
                (name-str (format nil "(name . ~S)" title))
                (title-str (format nil "(title . ~S)" title))
                (form (format nil "(~A ~A)" name-str title-str))
                (args (list "/usr/bin/emacsclient" "-c" "-F" (string-escape form)))
                (client-cmd (str:join " " args))
                (non-client-cmd (format nil "/usr/bin/emacs --title ~S --name ~S" title title)))
           (list :title title
                 :client-cmd client-cmd
                 :non-client-cmd non-client-cmd))))
  (defapp display-named-emacs (name &optional force-serverless)
      ((:string "Name: ") (:y-or-n "Force server-less: "))
      ("Emacs")
    "Raise emacs frame with given name"
    (let ((plist (emacs-name-plist name)))
      (if (and (not force-serverless)
               (emacs-daemon-running-p))
          (run-or-raise (getf plist :client-cmd) `(:title ,(getf plist :title)))
          (run-or-raise (getf plist :non-client-cmd) `(:title ,(getf plist :title)))))))
||#

;; (defapp run-yakyak () () ("IM")
;;   "Run Yakyak"
;;   (run-or-raise "yakyak" '(:class "yakyak")))
