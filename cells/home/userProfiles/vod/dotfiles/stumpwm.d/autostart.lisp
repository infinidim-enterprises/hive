(in-package :vod)

(defun autostart-env ()
  (mapc
   #'(lambda (cmd) (run-shell-command cmd))
   (list
    "xsetroot -solid '#002b36' -name root-window"
    "xset b off" ))
  (run-commands "tilix"))

(autostart-env)
