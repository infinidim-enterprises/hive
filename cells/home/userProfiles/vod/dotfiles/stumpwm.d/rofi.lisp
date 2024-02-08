(in-package :vod)

(setf *xdg-data-dirs* (cl-strings:split (getenv "XDG_DATA_DIRS") #\:))

;; (length *xdg-data-dirs*)

;; TODO: better yet, replace rofi-drun and rofi-systemd, rofi-ssh with native lisp variants
(ql:quickload :desktop-entry)
(setf desktop-entry:*entry-paths* (asdf::getenv-absolute-directories "XDG_DATA_DIRS"))

(setf desktop-entry:*entry-paths* (asdf::getenv-absolute-directories (remove-duplicates (cl-strings:split "/nix/store/4rxdys03x7zlgpi3ws7zp0n613jrd0yg-tilix-1.8.3/share:/nix/store/65gjwg17kyxv5739bf49327rv7fq90id-gtk+3-3.22.30/share/gsettings-schemas/gtk+3-3.22.30:/nix/store/yp91dd9rz0vwlhvqb1nsj0kmbpijh363-gsettings-desktop-schemas-3.28.0/share/gsettings-schemas/gsettings-desktop-schemas-3.28.0:/nix/store/65gjwg17kyxv5739bf49327rv7fq90id-gtk+3-3.22.30/share/gsettings-schemas/gtk+3-3.22.30:/nix/store/65gjwg17kyxv5739bf49327rv7fq90id-gtk+3-3.22.30/share/gsettings-schemas/gtk+3-3.22.30:/nix/store/yp91dd9rz0vwlhvqb1nsj0kmbpijh363-gsettings-desktop-schemas-3.28.0/share/gsettings-schemas/gsettings-desktop-schemas-3.28.0:/nix/store/65gjwg17kyxv5739bf49327rv7fq90id-gtk+3-3.22.30/share/gsettings-schemas/gtk+3-3.22.30:/nix/store/4rxdys03x7zlgpi3ws7zp0n613jrd0yg-tilix-1.8.3/share/gsettings-schemas/tilix-1.8.3:/nix/store/4rxdys03x7zlgpi3ws7zp0n613jrd0yg-tilix-1.8.3/share:/nix/store/65gjwg17kyxv5739bf49327rv7fq90id-gtk+3-3.22.30/share/gsettings-schemas/gtk+3-3.22.30:/nix/store/yp91dd9rz0vwlhvqb1nsj0kmbpijh363-gsettings-desktop-schemas-3.28.0/share/gsettings-schemas/gsettings-desktop-schemas-3.28.0:/nix/store/65gjwg17kyxv5739bf49327rv7fq90id-gtk+3-3.22.30/share/gsettings-schemas/gtk+3-3.22.30:/nix/store/65gjwg17kyxv5739bf49327rv7fq90id-gtk+3-3.22.30/share/gsettings-schemas/gtk+3-3.22.30:/nix/store/yp91dd9rz0vwlhvqb1nsj0kmbpijh363-gsettings-desktop-schemas-3.28.0/share/gsettings-schemas/gsettings-desktop-schemas-3.28.0:/nix/store/65gjwg17kyxv5739bf49327rv7fq90id-gtk+3-3.22.30/share/gsettings-schemas/gtk+3-3.22.30:/nix/store/4rxdys03x7zlgpi3ws7zp0n613jrd0yg-tilix-1.8.3/share/gsettings-schemas/tilix-1.8.3:/run/opengl-driver/share:/home/vod/.nix-profile/share:/nix/var/nix/profiles/default/share:/run/current-system/sw/share:/etc/profiles/per-user/vod/share" #\:))))

(desktop-entry:init-entry-list)
(describe desktop-entry:*entry-list*)

(stumpwm:list-directory (first *xdg-data-dirs*))


(defvar dentries (directory (make-pathname :directory `(,@(pathname-directory "/run/current-system/sw/share")
                                         :wild-inferiors)
                          :name :wild
                          :type "desktop")))
(length dentries)

(dolist (entry-file dentries)
  (setf desktop-entry:*entry-list*
        (desktop-entry:add-to-entry-list desktop-entry:*entry-list* entry-file)))

#||

(defun pass-entries ()
  (let ((home-ns-len (length (namestring *password-store-dir*))))
    (mapcar
     (lambda (entry)
       (let ((entry-ns (namestring entry)))
         (subseq entry-ns home-ns-len (- (length entry-ns) 4))))
     (directory (make-pathname :directory `(,@(pathname-directory *password-store-dir*)
                                            :wild-inferiors)
                               :name :wild
                               :type "gpg"))

     )))

(setf desktop-entry:*entry-paths*
'(#P"/run/current-system/sw/share/applications"
#P(format nil "~A/.local/share/applications" (getenv "HOME"))

))
;; (describe #P"/run/current-system/sw/share/applications")
;; (describe (merge-pathnames (concat (getenv "HOME") "/" ".local/share/applications")) )
||#
