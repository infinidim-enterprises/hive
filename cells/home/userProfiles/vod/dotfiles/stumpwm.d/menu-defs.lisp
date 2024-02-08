(in-package :vod)

;; (define-key *top-map* (kbd "M-`") "show-menu")

(defparameter *menu-screenshot*
      '( ("screen_Shot"
         ("with Stumpwm"
          ("current window" "screenshot-window")
          ("desktop" "screenshot"))
         ("with Scrot" "scrot-screenshot"))
        ("screen_Record" "screenrecord")))

(defparameter *lang-menu*
  '(
    ("en_US" "setxkbmap -query")
    ("ru_Phonetic" "setxkbmap -query")
    ("de_DE" "setxkbmap -query")
    )
  )

(defparameter *menu-power*
  '(
    ("Lock Screen" "exec xscreensaver-command -lock")
    ("switch-to-greeter" "dm-tool switch-to-greeter")
    ;; ("Hibernate" "xscreensaver-command --lock && systemctl hibernate")
    ;; ("Suspend" "xscreensaver-command --lock && systemctl suspend")
    ("Quit StumpWM" system-logout)
    ("Reboot" system-reboot)
    ("Shutdown" system-shutdown)
    )
  )
;; TODO: loginctl terminate-session $(loginctl session-status)
;; startup run commands

(defparameter *menu-start*
  '(
    ("Internet"
     ("Firefox myDefault"  "/usr/lib/firefox/firefox -P myDefault")
     ("Chromium x1.5"  "/usr/bin/chromium --force-device-scale-factor=1.5")
     ("Firefox -ProfileManager" "/usr/lib/firefox/firefox -ProfileManager -new-instance")
     ;; ("Sabnzbd+" "sabnzbdplus --server 127.0.0.1:8090 --browser 0")
     )

    ("Terminals"
     ("Retro-cool" "gtk-launch cool-retro-term")
     ("Kitty" "gtk-launch kitty"))

    ("X Windows Tools"
     ("xclipboard"  "xclipboard")
     ("xfontsel"      "xfontsel")
     ("xev"     "xev"))
    ))

(defparameter *menu-heads*
  '(
    ("[Full-desktop-mode]" desktop-full-via-systemd)
    ("[DSI-1:1920x1200]" desktop-single-head-via-systemd)
    ("[DSI-1:1920x1200] [HDMI-1:1920x1080]" "desktop-dual-head")
    ("[VNC:1920x1080] [VNC:1920x1080] [VNC:2560x1600] [DSI-1:1920x1200] [HDMI-1:1920x1080]" "desktop-quintuple-head")
    ("[VNC:2560x1600] [DSI-1:1920x1200]" desktop-dual-head-mobile-via-systemd)
    ("[VNC:1600x2560] [DSI-1:1920x1200]" desktop-dual-head-mobile-v-via-systemd)
    )
  )
