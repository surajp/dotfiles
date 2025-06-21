#!/usr/bin/env bash

#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ key-bindings.bash
#
# - $FZF_TMUX_OPTS
# - $FZF_CTRL_T_COMMAND
# - $FZF_CTRL_T_OPTS
# - $FZF_CTRL_R_OPTS
# - $FZF_ALT_C_COMMAND
# - $FZF_ALT_C_OPTS

# Key bindings
# ------------

if [[ $- =~ i ]]; then
  declare -A commandsmap
  commandsmap=(
    ["heroku"]="$HOME/.herokucommands.json"
    ["sfdx"]="$HOME/.sfdxcommands.json"
    ["sf"]="$HOME/.sfcommands.json"
  )

  fzf-emojis() {
    selectedSmiley="$(cat ~/.emojis.txt | $(__fzfcmd) | cut --fields=1 --delimiter=' ')"
    READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selectedSmiley${READLINE_LINE:$READLINE_POINT}"
    READLINE_POINT=$((READLINE_POINT + ${#selectedSmiley}))
  }

  fzf-soql() {
    local sobjtypesDir="$HOME/.sobjtypes"
    [[ ! -d "$sobjtypesDir" ]] && mkdir "$sobjtypesDir"

    local targetOrg=""
    if [[ $READLINE_LINE == *" -o "* ]]; then
      targetOrg=${READLINE_LINE##* -o }
      targetOrg=${targetOrg%% *}
    elif [[ $READLINE_LINE == *" --target-org "* ]]; then
      targetOrg=${READLINE_LINE##* --target-org }
      targetOrg=${targetOrg%% *}
    fi

    local orgId="default"
    if [[ -n "$targetOrg" ]]; then
      orgId=$targetOrg
    else
      if [[ -f .sf/config.json ]]; then
        orgId=$(jq -r '.["target-org"] // empty' .sf/config.json)
      else
        return 1
      fi
    fi

    local orgDir="$sobjtypesDir/$orgId"
    [[ ! -d "$orgDir" ]] && mkdir "$orgDir"

    local customFieldsFile="$orgDir/customFields.json"
    local shouldRefresh=false
    if [[ -n "$FZF_REFRESH" ]]; then
      shouldRefresh=true
    fi
    if [[ "$READLINE_LINE" == *"REF=1"* ]]; then
      shouldRefresh=true
    fi
    if [[ ! -f "$customFieldsFile" || "$shouldRefresh" == true ]]; then
      echo "\nLoading data, please wait..." >&2
      if [[ -n "$targetOrg" ]]; then
        sfdx data:query -q "select EntityDefinition.QualifiedApiName,DeveloperName,NamespacePrefix from customfield" -t -o "$targetOrg" --json > "$customFieldsFile"
      else
        sfdx data:query -q "select EntityDefinition.QualifiedApiName,DeveloperName,NamespacePrefix from customfield" -t --json > "$customFieldsFile"
      fi
    fi

    temp_file="/tmp/customFields.json"
    jq 'del(.result.records[] | select(.EntityDefinition.QualifiedApiName == null))' "$customFieldsFile" > "$temp_file" && mv "$temp_file" "$customFieldsFile"

    if [[ ! -f ~/.sobjtypes/sf_standard_schema.csv ]]; then
      curl -sSL "https://gist.githubusercontent.com/surajp/2282582350226fc9e2a268633b5e06aa/raw/9efc2c60799965ab1554d30ad1987472cbf8c654/sfschema.txt" -o ~/.sobjtypes/sf_standard_schema.csv
    fi
    local selected
    local linethusfar="${READLINE_LINE:0:$READLINE_POINT}"
    local precedingWord="${linethusfar% *}"
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
      } | sort -u | $(__fzfcmd) -i)"
    fi
    selected="${selected#*.}"
    READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
    READLINE_POINT=$((READLINE_POINT + ${#selected}))
  }

  fzf-sfdx-alias() {
    local selected=$(cat ~/.sfdxaliases | jq -r '.. | objects | select(.username!=null) | .username+", "+.alias' | sort | uniq | $(__fzfcmd) -d ',' --preview "jq -r --arg sel {1} '[.. | objects | select(.username==\$sel) ][0] | del(.accessToken)' ~/.sfdxaliases" | awk -F "," 'function trim(s){sub(/^[ \t]+/,"",s);sub(/[ \t]+$/,"",s);return s} {print (trim($2)=="") ?$1:trim($2)}')
    READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
    READLINE_POINT=$((READLINE_POINT + ${#selected}))
  }

  fzf-sfdx-mdapiTypes() {
    local selected="$(jq -r '.types | to_entries[] | select (.value.channels.metadataApi=true).key' ~/.mdapiReport.json | $(__fzfcmd) -i)"
    READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
    READLINE_POINT=$((READLINE_POINT + ${#selected}))
  }

  fzf_sfdx_flags() {
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
    local fullcmd="$READLINE_LINE"
    local cmd="${fullcmd%% *}"
    cmd="${cmd:-sfdx}" # Set cmd to "sfdx" if it's empty
    local thefile="${commandsmap[$cmd]:-}"
    if [[ -z "$thefile" ]]; then
      return 0
    fi

    local subcmd
    subcmd=$(echo "${fullcmd#$cmd}" | awk -F " -" '{print $1}' | awk '{$1=$1};1')
    local match
    match=$(jq -r --arg subcmd "$subcmd" '.[] | select(.id==$subcmd)' "$thefile")

    if [[ -n "$match" ]]; then
      local flag
      flag=$(fzf_sfdx_flags "$subcmd" "$fullcmd")
      if [[ -n "$flag" ]]; then
        READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}--$flag${READLINE_LINE:$READLINE_POINT}"
        READLINE_POINT=$((READLINE_POINT + ${#flag} + 3))
      fi
    else
      local querystr=""
      if [[ -n "$subcmd" ]]; then
        querystr="--query=$subcmd"
      fi
      local selected
      selected=$(jq -r '.[].id' "$thefile" |
        fzf +m --bind='ctrl-z:ignore,alt-j:preview-down,alt-k:preview-up' \
          --preview="jq -r --arg id {} '.[] | select(.id==\$id) | [\"\nDescription:\n \"+.description,\"\nUsage:\n \"+(select(has(\"usage\")).usage), \"\nExamples:\n \"+(select(has(\"examples\")).examples | if type==\"array\" then join(\"\n\") else . end)][]' $thefile" \
          --preview-window='right:wrap' $querystr)
      if [[ -n "$selected" ]]; then
        READLINE_LINE="$cmd $selected"

        READLINE_POINT=$((READLINE_POINT + ${#cmd} + ${#selected} + 1))
      fi
    fi
  }

  fzf-search-packages() {
    read -p "Enter Package Name: " packagename
    #echo $packagename
    selectedPackage="$(apt-cache search $packagename | fzf -m --bind=ctrl-z:ignore,alt-j:preview-down,alt-k:preview-up | awk '{print $1}')"
    # selectedPackage="$(apt-cache search $packagename | fzf -m --bind=ctrl-z:ignore,alt-j:preview-down,alt-k:preview-up --preview 'echo "{}" | awk ''{print $1}'' | apt show' --preview-window='right:wrap' | awk '{print $1}')"
    if [[ "$selectedPackage" != "" ]]; then
      echo "$(sudo apt-get install $selectedPackage)"
    fi
  }

  alias pacs='fzf-search-packages'

  # CTRL-3 - Paste the selected emoji into the command line
  bind -m emacs-standard -x '"\C-3": fzf-emojis'
  bind -m vi-command -x '"\C-3": fzf-emojis'
  bind -m vi-insert -x '"\C-3": fzf-emojis'

  # CTRL-e - Search for and paste the selected sfdx command onto the command line
  bind -m emacs-standard -x '"\C-e": fzf-autocomp'
  bind -m vi-command -x '"\C-e": fzf-autocomp'
  bind -m vi-insert -x '"\C-e": fzf-autocomp'

  # CTRL-n - Search for and paste the selected sfdx org from the authorized orglist onto the command line
  bind -m emacs-standard -x '"\C-n": fzf-sfdx-alias'
  bind -m vi-command -x '"\C-n": fzf-sfdx-alias'
  bind -m vi-insert -x '"\C-n": fzf-sfdx-alias'

  # CTRL-y - Search for and paste the selected field or SObject into your SOQL query
  bind -m emacs-standard -x '"\C-y": fzf-soql'
  bind -m vi-command -x '"\C-y": fzf-soql'
  bind -m vi-insert -x '"\C-y": fzf-soql'

  # CTRL-/ - Search for paste the selected metadata type onto the command line for retrieving
  bind -m emacs-standard -x '"\C-]": fzf-sfdx-mdapiTypes'
  bind -m vi-command -x '"\C-]": fzf-sfdx-mdapiTypes'
  bind -m vi-insert -x '"\C-]": fzf-sfdx-mdapiTypes'

fi

if [[ -f ~/fzf-extras.bash ]]; then
  source ~/fzf-extras.bash
fi
