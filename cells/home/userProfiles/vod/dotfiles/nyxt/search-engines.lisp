(in-package #:nyxt-user)

;; the context-buffer search-engines are sorted alphabetically
;; and *dc/search-engines* is appended to the slot value
;; https://github.com/atlas-engineer/nyxt/blob/97c0b4164df88e9e610b3237d7e304539abae618/source/buffer.lisp#L592
(defvar *dc/search-engines*
  (list
   ;; google:
   ;;
   ;; - &udm=14 disables AI results (supposedly; for now)
   ;; - &tbs=li:1 disable fuzzy search
   '("g"
     "https://google.com/search?q=~a&udm=14&tbs=li:1"
     "https://google.com")
   '("go"
     "https://google.com/search?q=~a&udm=14"
     "https://google.com")
   '("gfuzz"
     "https://google.com/search?q=~a"
     "https://google.com")
   '("doi"
     "https://dx.doi.org/~a"
     "https://dx.doi.org/")
   '("py"
     "https://docs.python.org/3/search.html?q=~a"
     "Python 3 (Docs)")
   '("ansd"
     "https://docs.ansible.com/ansible/latest/index.html#stq=~a&stp=1"
     "Ansible (Docs)")
   '("ansg"
     "https://galaxy.ansible.com/search?deprecated=false&keywords=~a&order_by=-download_count&page=1"
     "Ansible (Galaxy)")

   ;; github
   '("gh"
     "https://github.com/~a"
     "Github (URL)")
   '("ghi"
     "https://github.com/search?q=~a&type=issues"
     "Github (Issues)")
   '("ghp"
     "https://github.com/search?q=~a&type=pullrequests"
     "Github (Pull Reqs)")
   '("ght"
     "https://github.com/search?q=~a&type=topics"
     "Github (Topics)")
   '("npm"
     "https://www.npmjs.com/search?q=~a"
     "NPM")
   '("kdesrc"
     "https://lxr.kde.org/ident?v=kf6-qt6&_i=~a"
     "https://www.npmjs.com/"))
  "List of search engines.")

;; TODO: consider using ©hárß for urls without search
;; '("á©" "https://galaxy.ansible.com/community") ; no URL for community

(define-configuration context-buffer
  "Go through the search engines above and make-search-engine out of them."
  ((search-engines
    (append
     (mapcar (lambda (engine) (apply 'make-search-engine engine))
             *dc/search-engines*)
     %slot-default%))))
