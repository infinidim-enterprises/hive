;; -*- mode: common-lisp -*-
;;* Nyxt
(in-package #:nyxt-user)

(asdf:clear-source-registry)

(defun getenv (var)
  (values (sb-ext:posix-getenv var)))

(define-nyxt-user-system-and-load nyxt-user/basic-config
  :components ("status" "search-engines" "keys" "theme"))

(define-nyxt-user-system-and-load "nyxt-user/dark-reader"
  :components ("dark-reader.lisp")
  :depends-on (:nx-dark-reader))
