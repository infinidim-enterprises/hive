;; -*- mode: common-lisp -*-
;;* Nyxt
(in-package #:nyxt-user)

;; When you omit the values for on-colors, they're automatically set
;; to either `theme:text-color' or `theme:contrast-text-color',
;; according to what achieves a better contrast.

(defvar solarized-dark-theme (make-instance 'theme:theme
                                            :dark-p t

                                            :background-color+ "#002b36"  ; base03
                                            :background-color  "#073642"  ; base02
                                            :background-color- "#002b36"  ; base03
                                            :on-background-color "#839496" ; base0 (foreground)

                                            ;; :text-color- "#657b83"            ; base00
                                            ;; :text-color "#839496"             ; base0
                                            ;; :text-color+ "#93a1a1"            ; base1
                                            ;; :contrast-text-color "#fdf6e3"    ; base3

                                            :primary-color+    "#839496"  ; base0 (focused elements)
                                            :primary-color     "#657b83"  ; base00
                                            :primary-color-    "#586e75"  ; base01
                                            :on-primary-color  "#002b36"  ; base03 (contrast for primary)

                                            :secondary-color+  "#93a1a1"  ; base1
                                            :secondary-color   "#839496"  ; base0
                                            :secondary-color-  "#657b83"  ; base00
                                            :on-secondary-color "#002b36" ; base03 (contrast for secondary)

                                            :action-color+    "#839496"  ; base0 (focused elements)
                                            :action-color     "#657b83"  ; base00
                                            :action-color-    "#586e75"  ; base01
                                            :on-action-color  "#002b36"  ; base03 (contrast for primary)

                                            ;; :action-color+     "#268bd2"  ; blue (focused/important elements)
                                            ;; :action-color      "#2aa198"  ; cyan
                                            ;; :action-color-     "#859900"  ; green
                                            ;; :on-action-color   "#002b36"  ; base03 (contrast for action)

                                            :highlight-color+  "#b58900"  ; yellow (attention-grabbing)
                                            :highlight-color   "#cb4b16"  ; orange
                                            :highlight-color-  "#dc322f"  ; red
                                            :on-highlight-color "#002b36" ; base03 (contrast for highlight)

                                            :success-color+    "#859900"  ; green (success)
                                            :success-color     "#2aa198"  ; cyan
                                            :success-color-    "#268bd2"  ; blue
                                            :on-success-color  "#002b36"  ; base03 (contrast for success)

                                            :warning-color+    "#dc322f"  ; red (errors/warnings)
                                            :warning-color     "#cb4b16"  ; orange
                                            :warning-color-    "#b58900"  ; yellow
                                            :on-warning-color  "#002b36"  ; base03 (contrast for warning)


                                            ;; ACCEPTABLE_START
                                            ;;
                                            ;; :background-color- "#073642"      ; base02
                                            ;; :background-color  "#002b36"      ; base03
                                            ;; :background-color+ "#586e75"      ; base01
                                            ;; :on-background-color "#93a1a1"    ; base1

                                            ;; :primary-color- "#586e75"         ; base01
                                            ;; :primary-color "#657b83"          ; base00
                                            ;; :primary-color+ "#839496"         ; base0
                                            ;; :on-primary-color "#fdf6e3"       ; base3

                                            ;; :secondary-color- "#839496"       ; base0
                                            ;; :secondary-color "#93a1a1"        ; base1
                                            ;; :secondary-color+ "#eee8d5"       ; base2
                                            ;; :on-secondary-color "#002b36"     ; base03

                                            ;; :action-color- "#586e75"          ; base01
                                            ;; :action-color "#839496"           ; base0
                                            ;; :action-color+ "#93a1a1"          ; base1
                                            ;; :on-action-color "#002b36"        ; base03

                                            ;; :highlight-color- "#657b83"       ; base00
                                            ;; :highlight-color "#839496"        ; base0
                                            ;; :highlight-color+ "#93a1a1"       ; base1
                                            ;; :on-highlight-color "#002b36"     ; base03

                                            ;; :success-color- "#586e75"         ; base01
                                            ;; :success-color "#657b83"          ; base00
                                            ;; :success-color+ "#839496"         ; base0
                                            ;; :on-success-color "#002b36"       ; base03

                                            ;; :warning-color- "#586e75"         ; base01
                                            ;; :warning-color "#657b83"          ; base00
                                            ;; :warning-color+ "#839496"         ; base0
                                            ;; :on-warning-color "#002b36"       ; base03

                                            ;; :codeblock-color- "#586e75"       ; base01
                                            ;; :codeblock-color "#657b83"        ; base00
                                            ;; :codeblock-color+ "#839496"       ; base0
                                            ;; :on-codeblock-color "#fdf6e3"     ; base3

                                            ;; :text-color- "#657b83"            ; base00
                                            ;; :text-color "#839496"             ; base0
                                            ;; :text-color+ "#93a1a1"            ; base1
                                            ;; :contrast-text-color "#fdf6e3"    ; base3

                                            ;; ACCEPTABLE_END



                                            ;;;; maybe
                                            ;; :text-color- "#657b83"            ; base00
                                            ;; :text-color "#839496"             ; base0
                                            ;; :text-color+ "#93a1a1"            ; base1
                                            ;; :contrast-text-color "#fdf6e3"    ; base3

                                            ;;;; old palette

                                            ;; :text-color- "#839496"
                                            ;; :text-color "#839496"
                                            ;; :text-color+ "#839496"
                                            ;; :contrast-text-color "#002b36"

                                            ;; :action-color- "#073642"
                                            ;; :action-color "#073642"
                                            ;; :action-color+ "#073642"
                                            ;; :on-action-color "#839496"

                                            ;; :background-color- "#073642"
                                            ;; :background-color "#002b36"
                                            ;; :background-color+ "#073642"
                                            ;; :on-background-color "#839496"

                                            ;; :codeblock-color- "#073642"
                                            ;; :codeblock-color "#073642"
                                            ;; :codeblock-color+ "#073642"
                                            ;; :on-codeblock-color "#073642"

                                            ;; :highlight-color- "#ffefbf"
                                            ;; :highlight-color "#fac090"
                                            ;; :highlight-color+ "#d7c20a"
                                            ;; :on-highlight-color "#d7c20a"

                                            ;; :primary-color- "#073642"
                                            ;; :primary-color "#073642"
                                            ;; :primary-color+ "#073642"
                                            ;; :on-primary-color "#839496"

                                            ;; :secondary-color- "#073642"
                                            ;; :secondary-color "#073642"
                                            ;; :secondary-color+ "#073642"
                                            ;; :on-secondary-color "#2aa198"

                                            ;; :success-color- "#d8f8e1"
                                            ;; :success-color "#aee5be"
                                            ;; :success-color+ "#8cca8c"
                                            ;; :on-success-color "#8cca8c"

                                            ;; :warning-color- "#cb4b16"
                                            ;; :warning-color "#dc322f"
                                            ;; :warning-color+ "#d33682"
                                            ;; :on-warning-color "#d33682"

                                            :font-family "UbuntuMono Nerd Font Mono"
                                            :monospace-font-family "UbuntuMono Nerd Font Mono"))

(define-configuration browser ((theme solarized-dark-theme)))

;; ---------------------------------------------------------
;; change fonts
;; ---------------------------------------------------------
(defmethod ffi-buffer-make :after ((buffer nyxt/renderer/gtk:gtk-buffer))
  "Set fonts for the WebKitGTK renderer."
  (let ((settings (webkit:webkit-web-view-get-settings (nyxt/renderer/gtk:gtk-object buffer))))
    (setf (webkit:webkit-settings-serif-font-family settings) "UbuntuMono Nerd Font Mono"
          (webkit:webkit-settings-sans-serif-font-family settings) "UbuntuMono Nerd Font Mono"
          (webkit:webkit-settings-monospace-font-family settings) "UbuntuMono Nerd Font Mono")))

#||

SOLARIZED HEX     16/8 TERMCOL  XTERM/HEX   L*A*B      RGB         HSB
--------- ------- ---- -------  ----------- ---------- ----------- -----------
base03    #002b36  8/4 brblack  234 #1c1c1c 15 -12 -12   0  43  54 193 100  21
base02    #073642  0/4 black    235 #262626 20 -12 -12   7  54  66 192  90  26

base01    #586e75 10/7 brgreen  240 #585858 45 -07 -07  88 110 117 194  25  46
base00    #657b83 11/7 bryellow 241 #626262 50 -07 -07 101 123 131 195  23  51
base0     #839496 12/6 brblue   244 #808080 60 -06 -03 131 148 150 186  13  59
base1     #93a1a1 14/4 brcyan   245 #8a8a8a 65 -05 -02 147 161 161 180   9  63

base2     #eee8d5  7/7 white    254 #e4e4e4 92 -00  10 238 232 213  44  11  93
base3     #fdf6e3 15/7 brwhite  230 #ffffd7 97  00  10 253 246 227  44  10  99

yellow    #b58900  3/3 yellow   136 #af8700 60  10  65 181 137   0  45 100  71
orange    #cb4b16  9/3 brred    166 #d75f00 50  50  55 203  75  22  18  89  80
red       #dc322f  1/1 red      160 #d70000 50  65  45 220  50  47   1  79  86
magenta   #d33682  5/5 magenta  125 #af005f 50  65 -05 211  54 130 331  74  83
violet    #6c71c4 13/5 brmagenta 61 #5f5faf 50  15 -45 108 113 196 237  45  77
blue      #268bd2  4/4 blue      33 #0087ff 55 -10 -45  38 139 210 205  82  82
cyan      #2aa198  6/6 cyan      37 #00afaf 60 -35 -05  42 161 152 175  74  63
green     #859900  2/2 green     64 #5f8700 60 -20  65 133 153   0  68 100  60|#

||#
