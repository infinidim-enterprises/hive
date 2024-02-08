(in-package :vod)
(require :desktop-notifications)

(defun init-notifications ()
  (desktop-notifications:on)

  (defcommand notifications-show-all () ()
    (desktop-notifications:menu-show-all-msgs))

  (defcommand notifications-reset () ()
    "Desktop notifications Reset"
    (desktop-notifications:reset))

  (defcommand notifications-show-all-per-app () ()
    (desktop-notifications:menu-show-apps-as-categories))

  (defkeys-root
      ("s-n"    "notifications-show-all-per-app")
      ("s-r"    "notifications-reset")
      ("M-s-n"  "notifications-show-all")))

(init-notifications)
