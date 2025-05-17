fzf-bin(){
  local selectedCmd=$(ls -a /usr/bin /bin /usr/local/bin /usr/sbin/ | fzf -m --bind='alt-j:preview-down,alt-k:preview-up' --preview='tldr {}' --preview-window='right:wrap')
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selectedCmd${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$((READLINE_POINT + ${#selectedCmd}))
}
_fzf-fabric(){
  local selectedPattern=$(fabric -l| fzf -m --bind='alt-j:preview-down,alt-k:preview-up' --preview='bat ~/.config/fabric/patterns/{}/system.md' --preview-window='right:wrap')
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selectedPattern${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$((READLINE_POINT + ${#selectedPattern}))
}


# bind -m emacs-standard -x '"\ee": fzf-bin'
# bind -m vi-command -x '"\ee": fzf-bin'
# bind -m vi-insert -x '"\ee": fzf-bin'

bind -m emacs-standard -x '"\el":_fzf-fabric'
bind -m vi-command -x '"\el": _fzf-fabric'
bind -m vi-insert -x '"\el": _fzf-fabric'
