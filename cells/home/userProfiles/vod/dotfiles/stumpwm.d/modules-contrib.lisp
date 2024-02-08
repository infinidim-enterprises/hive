(in-package :vod)

(require :command-history)
(setf command-history::*command-history-file* (merge-pathnames
                                               (format nil "~A/.cache/stumpwm_cmd_history" (getenv "HOME"))))
