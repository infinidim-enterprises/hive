;;;; macro setting -*-lisp-*-
(in-package :vod)

(defmacro replace-hook (hook fn)
  `(remove-hook ,hook ,fn)
  `(add-hook ,hook ,fn))

;; FIXME:
;; (defmacro toggle-hook (hook fn)
;;   "Add or remove HOOK from fn"
;;   (if (member fn hook)
;;       ;; (remove-hook hook fn)
;;       ;; (message "hook found")
;;       `(remove-hook ,hook ',fn)
;;       `(add-hook ,hook ',fn)
;;       ;; (message "hook not found")
;;       ;; (add-hook hook fn)
;;       ))

(defmacro defkey-top (key cmd)
  `(define-key *top-map* (kbd ,key) ,cmd))

(defmacro defkeys-top (&rest keys)
  (let ((ks (mapcar #'(lambda (k) (cons 'defkey-top k)) keys)))
    `(progn ,@ks)))

(defmacro defkey-root (key cmd)
  `(define-key *root-map* (kbd ,key) ,cmd))

(defmacro defkeys-root (&rest keys)
  (let ((ks (mapcar #'(lambda (k) (cons 'defkey-root k)) keys)))
    `(progn ,@ks)))

(defmacro defkey-map (map key cmd)
  `(define-key map (kbd ,key) ,cmd))

;; I didn't use it and raised some warnings.. disabled
;; (defmacro defkeys-map (map &rest keys)
;;   (let ((ks (mapcar #'(lambda (k) (cons 'defkey-map map k)) keys)))
;;     `(progn ,@ks)))

;; sudo command definitions
(define-stumpwm-type :password (input prompt)
  (let ((history *input-history*)
        (arg (argument-pop input))
        (fn (symbol-function 'draw-input-bucket)))
    (unless arg
      (unwind-protect
           (setf (symbol-function 'draw-input-bucket)
                 (lambda (screen prompt input &optional errorp)
                   (let ((i (copy-structure input)))
                     (setf (input-line-string i)
                           (make-string (length (input-line-string i))
                                        :initial-element #\*))
                     (funcall fn screen prompt i)))
                 arg (read-one-line (current-screen) prompt))
        (setf (symbol-function 'draw-input-bucket) fn
              *input-history* history))
      arg)))

(defmacro define-sudo-command (name command &key output)
  (let ((cmd (gensym)))
    `(defcommand ,name (password) ((:password "sudo password: "))
                 (let ((,cmd (concat "echo '" password "' | sudo -S " ,command)))
                   ,(if output
                        `(run-prog-collect-output *shell-program* "-c" ,cmd)
                        `(run-prog *shell-program* :args (list "-c" ,cmd) :wait nil))))))


(defmacro def-run-or-raise-command (cmd prop)
  (let ((cmd-str (string-downcase (symbol-name cmd))))
    `(defcommand ,cmd () ()
       (run-or-raise ,cmd-str ,prop))))

;; process management, can do start-command-ps instead of run-shell-command
(defun ps-exists (ps)
  (let ((f "ps -ef | grep ~S | grep -v -e grep -e stumpish | wc -l"))
    (< 0 (parse-integer (run-shell-command (format nil f ps) t)))))

(defun start-command-ps (command &key options (background t))
  (unless (ps-exists command)
    (run-shell-command
     (concat command " " options " " (when background "&")))))

(defun kill-ps-command (command)
  (format nil "kill -TERM `ps -ef | grep ~S | grep -v grep | awk '{print $2}'`"
          command))

(defun kill-ps (command)
  (run-shell-command (kill-ps-command command)))

(defun terminal-command (name)
  "Start a gnome-terminal with an command session"
  (format nil "exec tilix -e ~a" name))
