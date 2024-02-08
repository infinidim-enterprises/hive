(in-package :vod)
(require :quri)
(require :drakma)
(require :yason)
(require :listopia)
(require :str)
(require :cl-ppcre)

(defun http-get (req)
  (let ((stream (drakma:http-request
                 req
                 :want-stream t
                 :decode-content t)))
    (setf (flexi-streams:flexi-stream-external-format stream) :utf-8)
    (yason:parse stream :object-as :hash-table)))

(defun http-get-as-plist (req)
  (let ((stream (drakma:http-request
                 req
                 :want-stream t
                 :decode-content t)))
    (setf (flexi-streams:flexi-stream-external-format stream) :utf-8)
    (yason:parse stream :object-as :plist)))
