(define-configuration nx-dark-reader:dark-reader-mode
  ((nxdr:brightness 100)
   (nxdr:contrast 100)
   ;; (nxdr:use-font t)
   ;; (nxdr:font-family "UbuntuMono Nerd Font Mono")
   ;; (nxdr:selection-color "#073642")
   (nxdr:background-color "#002b36")
   (nxdr:text-color "#839496")))

(define-configuration web-buffer
  ((default-modes `(nxdr:dark-reader-mode ,@%slot-value%))))
