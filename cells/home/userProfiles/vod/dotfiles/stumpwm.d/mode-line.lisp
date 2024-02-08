(in-package :vod)

;; (ql:quickload :net)
;; (ql:quickload :cpu)
;; (ql:quickload :mem)
(require :stumptray)

;; mode-line modules
(setf stumptray:*tray-placeholder-pixels-per-space* 11
      stumptray::*tray-win-background*              "#002b36"
      stumptray:*tray-viwin-background*             "#002b36"
      stumptray:*tray-hiwin-background*             "#002b36"
      ;; *tray-cursor-color*                           "#002b36"
      ;;disk:*disk-usage-paths*                       '("/")
      ;;disk:*disk-modeline-fmt*                      "[%m %p]"
      ;; NOTE: do conky for stats, stumpwm-modeline cannot be CPU intensive!
      ;; [%l] <- modeline fmt str
      ;; net:*net-device*                              "wlp1s0"
      ;; notifications::*notifications-delimiters*     '("/" "/")
      ;; battery-portable:*prefer-sysfs*               t
      )

(setf stumpwm:*mode-line-background-color* "#002b36"
      stumpwm:*mode-line-foreground-color* "#839496"
      stumpwm:*mode-line-border-color*     "#002b36"
      stumpwm:*mode-line-border-width*     0
      stumpwm:*mode-line-pad-x*            0
      stumpwm:*mode-line-pad-y*            0
      ;; stumpwm:*mode-line-screen-position*  :top
      stumpwm:*mode-line-timeout*          1
      stumpwm:*time-modeline-string*       "^7*^B%H:%M^b^n"
      ;; %N - notifications
      ;; %D - disk
      ;; %d - date/time
      ;; %T - stumptray

      ;; %l - network
      stumpwm:*screen-mode-line-format*    (list "[^B%n^b] "  "[%N]" "^>" " [%E] " "%d" "%T"))

;; TODO: perhaps something better?
(setf stumpwm:*mode-line-click-hook*
      (list #'(lambda (mode-line button x y)
                (declare (ignore mode-line x y))
                (cond ((eq button 3) (run-commands "next" "remove-split"))
                      ((eq button 2) (run-commands "gnext"))
                      ((eq button 1) (run-commands "prev" "remove-split"))))))

(if (not (stumpwm::head-mode-line (current-head)))
    (toggle-mode-line (current-screen) (current-head)))
