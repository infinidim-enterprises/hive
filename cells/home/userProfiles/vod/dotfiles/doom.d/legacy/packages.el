(package! solarized-theme)
(package! org-brain)
(package! polymode)
(package! windsize)
(package! beacon
          :recipe (:host github
                         :repo "Malabarba/beacon"
                         :branch "master"))

(package! move-text)
(package! highlight-indentation)
(package! smart-shift)

(package! forge)
;; (package! magit-org-todos)
(package! eyebrowse)
(package! counsel-projectile)
;; (package! company-quickhelp)
;; (package! company-lsp)
;; (package! company-restclient)

(package! lsp-ui)

(package! restclient)
(package! discover :recipe (:host github :repo "mickeynp/discover.el"))
(package! helm-tramp)
(package! vlf)
(package! imenu-list)
(package! w3m)
(package! ein :recipe (:host github
                             :repo "millejoh/emacs-ipython-notebook"
                             :files ("lisp/*.el")
                             :build (:not compile)))

;; (package! color-rg :recipe (:host github :repo "manateelazycat/color-rg"))

;; (package! snails :recipe (:host github
;;                                 :repo "manateelazycat/snails"
;;                                 :files ("*.el")))

(package! iscroll :recipe (:host github
                                 :repo "casouri/iscroll"))
(package! helm-rg)
(package! fd-dired :recipe (:host github
                                  :repo "yqrashawn/fd-dired"))
(package! find-dupes-dired :recipe (:host github
                                          :repo "ShuguangSun/find-dupes-dired"))
(package! dogears :recipe (:host github
                                 :repo "alphapapa/dogears.el"))
(package! session-async :recipe (:host nil
                                       :repo "https://codeberg.org/FelipeLema/session-async.el.git"
                                       :files ("*")
                                       )
          )
;; (package! auto-save :recipe (:host github :repo "manateelazycat/auto-save"))

(package! sly)
