(in-package :vod)
(export 'my-debug)

;; TODO: Logs/stumpwm.log
;; (stumpwm::redirect-all-output
;;  (write-to-string (slot-value
;;   (uiop:subpathname*
;;    (getenv "HOME")
;;    "Logs/stumpwm.log") 'namestring)))

;;(setf stumpwm::*data-dir* 0)
(setf stumpwm::*debug-level* 0)

(defun my-debug (&rest data)
  (with-open-file (stream (uiop:subpathname* (user-homedir-pathname) "tmp/stumpwm.txt")
                          :direction :output
                          :if-exists :append
                          :if-does-not-exist :create)
    (format stream "~&~A" (first data))
    (loop for item in (rest data)
          do (format stream " ~A" item))
    (terpri stream)))

;; (my-debug (print "hello"))
