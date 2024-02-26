(require 'asdf)

(defun getenv (var)
  (values (sb-ext:posix-getenv var)))

(defun set-fasl-output-directory (directory)
  (check-type directory pathname)
  (asdf:clear-output-translations)
  (asdf:initialize-output-translations
   `(:output-translations
     (t ,(merge-pathnames #P "**/*.*" directory))
     :ignore-inherited-configuration
     :disable-cache)))

;; TEMPDIR is available inside runCommandNoCC
(set-fasl-output-directory (pathname (format nil (getenv "TEMPDIR"))))
(asdf:load-system :uiop)

(defun split-and-get-last-uiop (input-string)
  (let ((splits (uiop:split-string input-string :separator "/")))
    (car (last splits))))

(defun list-system-dependencies-to-file (system-name output-file)
  "List the dependencies of the given system and write them to a file, separated by commas."
  (let ((system (asdf:find-system system-name nil)))
    (if system
        (let ((dependencies (asdf:system-depends-on system)))
          (with-open-file (stream output-file
                                   :direction :output
                                   :if-exists :supersede
                                   :if-does-not-exist :create)
            (write-line (reduce
                          (lambda (a b) (format nil "~A,~A" a b))
                          dependencies) stream)))
        (error "System ~A not found." system-name))))

(defun main ()
  (let ((args (uiop:command-line-arguments)))
    (if (>= (length args) 2)
      (progn
        (push (format nil "~A/" (first args)) asdf:*central-registry*)
        (list-system-dependencies-to-file
          (split-and-get-last-uiop (first args))
          (second args)))
        (format t "Usage: ~A <path-to-system> <output-file>~%"
          (car (last (uiop:command-line-arguments)))))))

(main)
