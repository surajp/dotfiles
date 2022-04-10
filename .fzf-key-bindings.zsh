#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ key-bindkeyings.bash
#

# Key bindkeyings
# ------------

if [[ $- =~ i ]]; then

  declare -A commandsmap
  commandsmap[heroku]=~/.herokucommands.json
  commandsmap[sfdx]=~/.sfdxcommands.json
  commandsmap[sf]=~/.sfcommands.json

  fzf-emojis(){
    selectedSmiley="$(cat ~/.emojis.txt | $(__fzfcmd) | cut --fields=1 --delimiter=' ')"
    LBUFFER="${LBUFFER:0:$CURSOR}$selectedSmiley${LBUFFER:$CURSOR}"
    CURSOR=$(( CURSOR + ${#selectedSmiley} ))
    local ret=$?
    zle reset-prompt
    return $ret
  }

  fzf-soql(){
    local linethusfar="${LBUFFER:0:$CURSOR}"
    echo "query is "
    local query="$(echo -e "${linethusfar%* }" | awk -F '[ ,.]' '{$NF=$NF;print $NF}')"
    if [[ -f "./schema.txt" ]]; then
      if [[ "$linethusfar" != *" " && "$linethusfar" != *"." && "$linethusfar" != *","   ]]; then
        local selected="$(cat ./schema.txt | $(__fzfcmd) -m -i --query $query | awk -F ' ' '{printf $1","}')"
        local tempReadPoint=$(( CURSOR - ${#query} ))
        LBUFFER="${LBUFFER:0:$tempReadPoint}${LBUFFER:$CURSOR}"
        #CURSOR=$tempReadPoint
      elif [[ "$query" = "from" && -f "./objects.txt" ]]; then
        local selected="$(cat ./objects.txt | $(__fzfcmd) -i)"
      else
        local selected="$(cat ./schema.txt | $(__fzfcmd) -m -i | awk -F ' ' '{printf $1","}')"
      fi
      LBUFFER="${LBUFFER:0:$CURSOR}$selected${LBUFFER:$CURSOR}"
    fi
    local ret=$?
    zle reset-prompt
    return $ret
  }
  zle -N fzf-soql{,}
  bindkey "^y" fzf-soql

  fzf-sfdx-alias(){
    local selected="$(cat ~/.sfdxaliases | $(__fzfcmd) | awk '{print $2}')"
    LBUFFER="${LBUFFER:0:$CURSOR}$selected${LBUFFER:$CURSOR}"
    local ret=$?
    zle reset-prompt
    return $ret
  }
  zle -N fzf-sfdx-alias{,}
  bindkey "^n" fzf-sfdx-alias

  fzf-sfdx-mdapiTypes(){
    local selected="$(jq -r '.types | to_entries[] | select (.value.metadataApi=true).key' ~/.mdapiReport.json | $(__fzfcmd) -i)"
    LBUFFER="${LBUFFER:0:$CURSOR}$selected${LBUFFER:$CURSOR}"
    local ret=$?
    zle reset-prompt
    return $ret
  }
  zle -N fzf-sfdx-mdapiTypes{,}
  bindkey "^_" fzf-sfdx-mdapiTypes

  fzf-sfdx-flags(){
    local cmd="$(echo $2 | awk '{print $1}')"
    if [[ "$cmd" == "" ]];
    then
      cmd="sfdx"
    fi
    thefile=${commandsmap[$cmd]}
    if [[ $thefile == "" ]]; then
     return 0
    fi
    local selected="$1"
    local fullcmd=""
    for i in "${@:2}"
    do fullcmd+=" ${i//\"/\\\\\\\"}" #we have to triple escape the double quotes here as it will be used within double quotes again in the command below
    done
    local ret=`cat $thefile | jq -r ".[] | select(.id==\"$selected\") | .flags | keys[]" | $(__fzfcmd) -m --bind='ctrl-z:ignore,alt-j:preview-down,alt-k:preview-up' --preview='cat '$thefile' | jq -r ".[] | select(.id==\"'$selected'\") | .flags | to_entries[] | select (.key==\""{}"\") | [\"Command:\n'"$fullcmd"'\n\",\"Flag Description:\",.value][]"' --preview-window='right:wrap'`
    echo "${ret//$'\n'/ --}"
  }

  fzf-autocomp(){
    local fullcmd="$LBUFFER"
    local cmd="$(echo $fullcmd | awk '{print $1}')"
    if [[ "$cmd" == "" ]];
    then
      cmd="sfdx"
    fi
    thefile=${commandsmap[$cmd]}
    if [[ $thefile == "" ]]; then
     return 0
    fi
    local subcmd="$(echo $fullcmd | awk '{print $2}')"
    local match="$(cat "$thefile" | jq -r '.[] | select(.id=="'$subcmd'")')"
    if [[ "$match" != "" ]]
    then
      local flag="$(fzf-sfdx-flags $subcmd $fullcmd)"
      if [[ "$flag" != "" ]]
      then
        LBUFFER="${LBUFFER:0:$CURSOR}--$flag${LBUFFER:$CURSOR}"
      fi
    else
      local querystr=""
      if [[ "$subcmd" != "" ]]; then
       querystr="--query=$subcmd"
      fi
      local selected="$(cat $thefile | jq -r '.[].id' | $(__fzfcmd) +m --bind=ctrl-z:ignore,alt-j:preview-down,alt-k:preview-up --preview='cat '$thefile' | jq -r ".[] | select (.id==\""{}"\") | [\"\nDescription:\n \"+.description,\"\nUsage:\n \"+select(has(\"usage\")).usage, \"\nExamples:\n \"+(select(has(\"examples\")).examples | if type==\"array\" then join(\"\n\") else . end)][]"' --preview-window='right:wrap' $querystr)"
      if [[ "$selected" != "" ]]; then
        LBUFFER="$cmd $selected"
      fi
    fi
    local ret=$?
    zle reset-prompt
    zle redisplay
    return $ret
  }

  zle -N fzf-autocomp{,}
  bindkey "^e" fzf-autocomp

  fzf-search-packages(){
    read -p "Enter Package Name: " packagename 
    #echo $packagename
    selectedPackage="$(apt-cache search $packagename | fzf -M | awk '{print $1}')"
    echo "$(sudo apt-get install $selectedPackage)"
  }
  zle -N fzf-search-packages{,}

fi
