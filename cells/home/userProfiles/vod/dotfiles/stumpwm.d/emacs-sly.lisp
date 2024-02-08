(in-package :vod)

(require :slynk)

(defvar *slynk-port* nil)
(when (null *slynk-port*) (setf *slynk-port* 4405))

(defvar *slynk-running-p* nil)

(defcommand slynk-start () ()
  "Start slynk REPL"
  (handler-case
      (slynk:create-server :port *slynk-port*
                           :dont-close t)
    (error (c)
      (message "^B^1*Slynk is running...^n"))
    (:no-error (&rest args)
      (declare (ignore args))
      (setf *slynk-running-p* t)
      (message "Slynk started...")))
  (run-shell-command "emacsclient --eval '(sly-stumpwm-start)'"))

(defcommand slynk-stop () ()
  "Stop slynk REPL"
  (run-shell-command "emacsclient --eval '(sly-stumpwm-stop)'")
  (ignore-errors (slynk:stop-server *slynk-port*))
  (setf *slynk-running-p* nil)
  (message "Slynk stopped..."))

(defcommand slynk-toggle () ()
  "Toggle slynk REPL"
  (if *slynk-running-p* (slynk-stop) (slynk-start)))
