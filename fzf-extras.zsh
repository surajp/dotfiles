#!/usr/bin/env zsh

_fzf-fabric(){
  local selectedPattern=$(fabric -l| fzf -m --bind='alt-j:preview-down,alt-k:preview-up' --preview='bat ~/.config/fabric/patterns/{}/system.md' --preview-window='right:wrap')
  if [[ -n "$selectedPattern" ]]; then
    LBUFFER="${LBUFFER:0:$CURSOR}fabric -sp $selectedPattern${LBUFFER:$CURSOR}"
    CURSOR=$((CURSOR + ${#selectedPattern} + 1))
    zle reset-prompt # Reset the prompt to prevent it from disappearing
  fi
}

zle -N _fzf-fabric
bindkey "^F" _fzf-fabric
