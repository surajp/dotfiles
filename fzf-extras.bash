fzf-bin(){
  local selectedCmd=$(ls -a /usr/bin /bin /usr/local/bin /usr/sbin/ | fzf -m --bind='alt-j:preview-down,alt-k:preview-up' --preview='tldr {}' --preview-window='right:wrap')
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selectedCmd${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$((READLINE_POINT + ${#selectedCmd}))
}


bind -m emacs-standard -x '"\ee": fzf-bin'
bind -m vi-command -x '"\ee": fzf-bin'
bind -m vi-insert -x '"\ee": fzf-bin'
