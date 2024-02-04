# list bindings: zle -al
# inspiration from: https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/lib/key-bindings.zsh
# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html

autoload -U edit-command-line
zle      -N edit-command-line

# Start typing + [Up-Arrow] - fuzzy find history forward
if [[ -n "${terminfo[kcuu1]}" ]]; then
    autoload -U up-line-or-beginning-search
    zle -N up-line-or-beginning-search
    bindkey -M emacs "${terminfo[kcuu1]}" up-line-or-beginning-search
fi

# Start typing + [Down-Arrow] - fuzzy find history backward
if [[ -n "${terminfo[kcud1]}" ]]; then
    autoload -U down-line-or-beginning-search
    zle -N down-line-or-beginning-search
    bindkey -M emacs "${terminfo[kcud1]}" down-line-or-beginning-search
fi

# [Delete] - delete forward
if [[ -n "${terminfo[kdch1]}" ]]; then
    bindkey -M emacs "${terminfo[kdch1]}" delete-char
else
    bindkey -M emacs "^[[3~" delete-char
    bindkey -M emacs "^[3;5~" delete-char
fi

# bindkey -M emacs "^R"       fzf-history-widget                     # [Ctrl-R]

bindkey -M emacs '^[<'      beginning-of-buffer-or-history         # [Alt-<]
bindkey -M emacs '^[[5;5~'  beginning-of-buffer-or-history         # [Ctrl-PageUp]
bindkey -M emacs '^[[6;5~'  end-of-buffer-or-history               # [Ctrl-PageDown]
bindkey -M emacs '^[>'      end-of-buffer-or-history               # [Alt->]
bindkey -M emacs '^?'       backward-delete-char                   # [Backspace]
bindkey -M emacs '^H'       backward-kill-word                     # [Ctrl-Backspace]
bindkey -M emacs '^[^?'     backward-kill-line                     # [Alt-Backspace]
bindkey -M emacs '^[[3;5~'  kill-word                              # [Ctrl-Delete]
bindkey -M emacs "^G"       send-break                             # [Ctrl-G]
bindkey -M emacs "^[^G"     _call_navi                             # [Ctrl-Alt-G]
bindkey -M emacs '^[[1;5C'  forward-word                           # [Ctrl-RightArrow]
bindkey -M emacs '^[[1;5D'  backward-word                          # [Ctrl-LeftArrow]
bindkey -M emacs '\C-h\k'   describe-key-briefly                   # [Ctrl-h k]
bindkey -M emacs '^[m'      copy-prev-shell-word                   # [Alt-m] file rename magick
bindkey -M emacs '^[e'      expand-cmd-path                        # [Alt-e]
bindkey -M emacs '\C-x\C-e' edit-command-line                      # [Ctrl-x Ctrl-e] - edit the current command line in $EDITOR
bindkey -M emacs ' '        magic-space                            # [Space] - don't do history expansion

# Quick-keys for commands
bindkey -s       '^[l'      'exa --group-directories-first -lgm\n' # [Alt-l]

# [Alt-W]
# "^[W" copy-region-as-kill
# bindkey '\ew' kill-region                           # [Esc-w] - Kill from the cursor to the mark
#bindkey -s '^X^Z' '%-^M'
#bindkey '^[^I' reverse-menu-complete
#bindkey '^X^N' accept-and-infer-next-history
#bindkey '^W' kill-region
#bindkey '^I' complete-word
# https://unix.stackexchange.com/questions/537178/zsh-using-different-wordchars-for-kill-word-and-forward-word-backward-word

''{back,for}ward-word() WORDCHARS=$MOTION_WORDCHARS zle .$WIDGET
zle -N backward-word
zle -N forward-word
