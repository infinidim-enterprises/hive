(in-package :vod)
;; (export '(after-load-conf))

(require :xembed)
(require :acl-compat)
(require :clx-truetype)
(require :ttf-fonts)

(defparameter *load-hooks* '())

(defun add-local-hook (name f)
  "Add a hook for running at the end of a local file."
  (push (list name f) *load-hooks*))

(defun run-local-hooks (name)
  (dolist (l (reverse *load-hooks*))
    (let ((local-name (first l))
          (f (second l)))
      (when (string= name local-name)
        (funcall f)))))

(defmacro after-load-conf ((name) &body body)
  `(add-local-hook ,name
                   #'(lambda ()
                       (eval '(progn ,@body)))))

(defun load-conf (name)
  "Load a config file in the *config-path*."
  (let ((file (merge-pathnames (concat name ".lisp") *config-path*)))
    (if (probe-file file)
      (progn
        (load file)
        (run-local-hooks file))
      (format *error-output* "'~a' not found!" file))))

(defun getenv (var)
  (values (sb-ext:posix-getenv var)))

(defun find-and-cache-fonts ()
  (let ((font-dir (or (getenv "HM_FONT_DIR")
                      (uiop:subpathname* (getenv "HOME")
                        ".local/share/fonts"))))
    (setf clx-truetype:*font-dirs* (list font-dir)))
  (setf clx-truetype::+font-cache-filename+ (concat (getenv "HOME") "/.cache/clx-truetype-font-cache.sexp"))
  (clx-truetype:cache-fonts))

(defun set-the-font ()
  (find-and-cache-fonts)
  (let* ((default-font "UbuntuMono Nerd Font Mono")
          (default-size "18")
          (file-path (uiop:subpathname* *config-path*
                       "nix-font-config.txt"))
          (cfg-file (awhen (probe-file file-path)
                      (split-string (uiop:read-file-string it))))
          (font-name (or (getenv "HM_FONT_NAME")
                       (car cfg-file)
                       default-font))
          (font-size (values (parse-integer (or (getenv "HM_FONT_SIZE")
                                              (car (cdr cfg-file))
                                              default-size))))
          (font-instance (make-instance 'xft:font
                           :family font-name
                           :subfamily "Regular"
                           ;; HACK/FIXME: have some lisp written by nix and preloaded with all the ENV
                           :size (* font-size 2))))
    (set-font font-instance))
  (message "Loaded ttf-fonts"))
(set-the-font)

;; NOTE: https://github.com/stumpwm/stumpwm/issues/474#issuecomment-481885037
(defun prevent-crash ()
  (loop for font in (stumpwm::screen-fonts (current-screen))
        when (typep font 'xft:font)
          do (clrhash (xft::font-string-line-bboxes font))
             (clrhash (xft::font-string-line-alpha-maps font))
             (clrhash (xft::font-string-bboxes font))
             (clrhash (xft::font-string-alpha-maps font))))

(run-with-timer 300 300 #'prevent-crash)

(defun dbg ()
  (let* ((font (first (stumpwm::screen-fonts (current-screen))))
         (xft-font-list (list
                         (xft::font-string-line-bboxes font)
                         (xft::font-string-line-alpha-maps font)
                         (xft::font-string-bboxes font)
                         (xft::font-string-alpha-maps font)))
         (op (lambda (x) (print (hash-table-count x)))))
    (describe font)
    (map nil op xft-font-list)))

;; (dbg)
;; TODO: https://github.com/TeMPOraL/tracer
