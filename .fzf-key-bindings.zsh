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

  fzf-emojis() {
    selectedSmiley="$(cat ~/.emojis.txt | $(__fzfcmd) | cut --fields=1 --delimiter=' ')"
    LBUFFER="${LBUFFER:0:$CURSOR}$selectedSmiley${LBUFFER:$CURSOR}"
    CURSOR=$((CURSOR + ${#selectedSmiley}))
    local ret=$?
    zle reset-prompt
    return $ret
  }

  fzf-soql() {
    local sobjtypesDir="$HOME/.sobjtypes"
    [[ ! -d "$sobjtypesDir" ]] && mkdir "$sobjtypesDir"

    local targetOrg=""
    if [[ $LBUFFER == *" -o "* ]]; then
      targetOrg=${LBUFFER##* -o }
      targetOrg=${targetOrg%% *}
    elif [[ $LBUFFER == *" --target-org "* ]]; then
      targetOrg=${LBUFFER##* --target-org }
      targetOrg=${targetOrg%% *}
    fi

    local orgId="default"
    if [[ -n "$targetOrg" ]]; then
      orgId=$targetOrg
    else
      orgId=$(jq -r '.["target-org"] // empty' .sf/config.json) 2> /dev/null
    fi

    local orgDir="$sobjtypesDir/$orgId"
    [[ ! -d "$orgDir" ]] && mkdir "$orgDir"

    local customFieldsFile="$orgDir/customFields.json"
    local shouldRefresh=false
    if [[ -n "$FZF_REFRESH" ]]; then
      shouldRefresh=true
    fi
    if [[ "$LBUFFER" == *"REF=1"* ]]; then
      shouldRefresh=true
    fi
    if [[ ! -f "$customFieldsFile" || "$shouldRefresh" == true ]]; then
      echo "\nLoading data, please wait..." >&2
      if [[ -n "$targetOrg" ]]; then
        sfdx data:query -q "select EntityDefinition.QualifiedApiName,DeveloperName,NamespacePrefix from customfield" -t -o "$targetOrg" --json > "$customFieldsFile" &> /dev/null
      else
        sfdx data:query -q "select EntityDefinition.QualifiedApiName,DeveloperName,NamespacePrefix from customfield" -t --json > "$customFieldsFile" &> /dev/null
      fi
    fi

    temp_file="/tmp/customFields.json"
    jq 'del(.result.records[] | select(.EntityDefinition.QualifiedApiName == null))' "$customFieldsFile" > "$temp_file" && mv "$temp_file" "$customFieldsFile"

    if [[ ! -f ~/.sobjtypes/sf_standard_schema.csv ]]; then
      curl -sSL "https://gist.githubusercontent.com/surajp/2282582350226fc9e2a268633b5e06aa/raw/9efc2c60799965ab1554d30ad1987472cbf8c654/sfschema.txt" -o ~/.sobjtypes/sf_standard_schema.csv
    fi
    local selected
    local precedingWord="${LBUFFER% *}"
    precedingWord="${precedingWord##* }"
    if [[ "$precedingWord" == "from" ]] || [[ "$precedingWord" == "FROM" ]]; then
      selected="$({
        jq -r '.result.records[] | "\(.EntityDefinition.QualifiedApiName)"' "$customFieldsFile"
        jq -Rr 'split(",") | .[0]' ~/.sobjtypes/sf_standard_schema.csv
      } | sort -u | $(__fzfcmd) -i)"
    else
      selected="$({
        jq -r '.result.records[] | "\(.EntityDefinition.QualifiedApiName)\(if .NamespacePrefix != null then ".\(.NamespacePrefix)__" else "." end)\(.DeveloperName)__c"' "$customFieldsFile"
        jq -Rr 'split(",") | "\(.[0]).\(.[1])"' ~/.sobjtypes/sf_standard_schema.csv
      } | sort -u | $(__fzfcmd) -i -m --preview="~/.fzf-soql-preview.zsh {1} $orgId" --preview-window='right:wrap' --bind='ctrl-z:ignore,alt-j:preview-down,alt-k:preview-up')"
    fi
    # Remove object prefix from each selected field
    selected=$(echo "$selected" | sed 's/[^.]*\.//g')
    # Convert newlines to commas for multi-select
    selected="${selected//$'\n'/,}"
    LBUFFER="${LBUFFER:0:$CURSOR}$selected${LBUFFER:$CURSOR}"

    zle reset-prompt
    return $?
  }

  zle -N fzf-soql{,}
  bindkey "^y" fzf-soql

  fzf-sfdx-alias() {
    local selected=$(cat ~/.sfdxaliases | jq -r '.. | objects | select(.username!=null) | .username+", "+.alias' | sort | uniq | $(__fzfcmd) -d ',' --preview "jq -r --arg sel {1} '[.. | objects | select(.username==\$sel) ][0] | del(.accessToken)' ~/.sfdxaliases" | awk -F "," 'function trim(s){sub(/^[ \t]+/,"",s);sub(/[ \t]+$/,"",s);return s} {print (trim($2)=="") ?$1:trim($2)}')
    LBUFFER="${LBUFFER:0:$CURSOR}$selected${LBUFFER:$CURSOR}"
    local ret=$?
    zle reset-prompt
    return $ret
  }
  zle -N fzf-sfdx-alias{,}
  bindkey "^n" fzf-sfdx-alias

  fzf-sfdx-mdapiTypes() {
    local selected="$(jq -r '.types | to_entries[] | select (.value.metadataApi=true).key' ~/.mdapiReport.json | $(__fzfcmd) -i)"
    LBUFFER="${LBUFFER:0:$CURSOR}$selected${LBUFFER:$CURSOR}"
    local ret=$?
    zle reset-prompt
    return $ret
  }

  zle -N fzf-sfdx-mdapiTypes{,}
  bindkey '^]' fzf-sfdx-mdapiTypes

  fzf-sfdx-selectMetdata() {
    local mdType=${LBUFFER##* }
    [[ $mdType != *: ]] && return 0
    if [[ ! -d ".mdtypes" ]]; then
      mkdir .mdtypes
    fi
    mdType=${mdType%:}
    local targetOrg=""
    if [[ $LBUFFER == *" -o "* ]]; then
      targetOrg=${LBUFFER##* -o }
      targetOrg=${targetOrg%% *}
    elif [[ $LBUFFER == *" --target-org "* ]]; then
      targetOrg=${LBUFFER##* --target-org }
      targetOrg=${targetOrg%% *}
    fi
    local selected=""
    local shouldRefresh=false
    if [[ -n "$FZF_REFRESH" ]]; then
      shouldRefresh=true
    fi
    if [[ "$LBUFFER" == *"REF=1"* ]]; then
      shouldRefresh=true
    fi
    if [[ ! -f .mdtypes/$mdType.json || "$shouldRefresh" == true ]]; then
      if [[ "$targetOrg" != "" ]]; then
        sfdx force:mdapi:listmetadata -m "$mdType" -o "$targetOrg" --json > .mdtypes/$mdType.json &> /dev/null
      else
        sfdx force:mdapi:listmetadata -m "$mdType" --json > .mdtypes/$mdType.json &> /dev/null
      fi
    fi
    selected=$(jq -r '.result[].fullName' .mdtypes/$mdType.json | $(__fzfcmd) -m -i)

    if [[ -n "$selected" ]]; then
      local formatted=""
      while IFS= read -r item; do
        formatted+="$mdType:\"$item\" "
      done <<< "$selected"
      LBUFFER="${LBUFFER%$mdType:}$formatted${LBUFFER:$CURSOR}"
    fi

    local ret=$?
    zle reset-prompt
    return $ret
  }

  zle -N fzf-sfdx-selectMetdata{,}
  bindkey '^[' fzf-sfdx-selectMetdata

  fzf-sfdx-flags() {
    local cmd="${2%% *}"
    cmd="${cmd:-sfdx}" # Set cmd to "sfdx" if it's empty
    thefile=${commandsmap[$cmd]}
    if [[ $thefile == "" ]]; then
      return 0
    fi
    local selected="$1"
    local fullcmd=""
    for i in "${@:2}"; do
      fullcmd+=" ${i//\"/\\\\\\\"}" #we have to triple escape the double quotes here as it will be used within double quotes again in the command below
    done
    local ret=$(jq -r --arg sel "$selected" '.[] | select(.id==$sel) | .flags | keys[]' "$thefile" | fzf -m --bind='ctrl-z:ignore,alt-j:preview-down,alt-k:preview-up' --preview="jq -r --arg sel '$selected' --arg key {} '.[] | select(.id==\$sel) | .flags | to_entries[] | select(.key==\$key) | [\"Command:\n$fullcmd\n\",\"Flag Description:\",.value][]' $thefile" --preview-window='right:wrap')
    echo "${ret//$'\n'/ --}"
  }

  fzf-autocomp() {
    local fullcmd="$LBUFFER"
    local cmd="$LBUFFER"
    cmd="${cmd##* }"
    local prevCmd=""
    local fullLine="$LBUFFER"
    # keep going back until we find a pipe or cmd has `=` in it
    while [[ $cmd != *"|"* && $cmd != *"="* && $cmd != *"&"* && $cmd != "time" ]]; do
      prevCmd=$cmd
      if [[ "$cmd" == "$fullLine" ]]; then
        break
      fi
      fullLine="${fullLine% *}"
      cmd="${fullLine##* }"
    done
    cmd=$prevCmd
    cmd="${cmd:-sfdx}" # Set cmd to "sfdx" if it's empty
    local thefile="${commandsmap[$cmd]:-}"
    if [[ $thefile == "" ]]; then
      return 0
    fi
    local prewords="${LBUFFER%$cmd*}"
    local subcmd=""
    if [[ "$fullcmd" == *"$cmd"* ]]; then
      subcmd=$(echo "${fullcmd#*$cmd}" | awk -F " -" '{print $1}' | awk '{$1=$1};1')
    fi
    local match=$(jq -r --arg subcmd "$subcmd" '.[] | select(.id==$subcmd)' "$thefile") # trim using jq
    match="${match#*\"}"
    if [[ "$match" != "" ]]; then
      local flag=$(fzf-sfdx-flags "$subcmd" "$cmd $subcmd")
      if [[ "$flag" != "" ]]; then
        LBUFFER="${LBUFFER:0:$CURSOR}--$flag${LBUFFER:$CURSOR}"
        CURSOR=$((CURSOR + ${#flag} + 3))
      fi
    else
      local querystr=""
      if [[ -n "$subcmd" ]]; then
        querystr="--query=$subcmd"
      fi
      local selected=$(jq -r '.[].id' "$thefile" |
        fzf +m --bind='ctrl-z:ignore,alt-j:preview-down,alt-k:preview-up' \
          --preview="jq -r --arg id {} '.[] | select(.id==\$id) | [\"\nDescription:\n \"+.description,\"\nUsage:\n \"+(select(has(\"usage\")).usage), \"\nExamples:\n \"+(select(has(\"examples\")).examples | if type==\"array\" then join(\"\n\") else . end)][]' $thefile" \
          --preview-window='right:wrap' $querystr)
      if [[ "$selected" != "" ]]; then
        LBUFFER="$prewords$cmd $selected"
        CURSOR=$((CURSOR + ${#cmd} + ${#selected} + 1))
      fi
    fi
    local ret=$?
    zle reset-prompt
    zle redisplay
    return $ret
  }

  zle -N fzf-autocomp{,}
  bindkey "^e" fzf-autocomp

  if [[ -f ~/.fzf-extras.zsh ]]; then
    source ~/.fzf-extras.zsh
  fi

fi
