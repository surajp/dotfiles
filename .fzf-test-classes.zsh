fzf-test-classes() {
  local targetOrg=""
  if [[ $LBUFFER == *" -o "* ]]; then
    targetOrg=${LBUFFER##* -o }
    targetOrg=${targetOrg%% *}
  elif [[ $LBUFFER == *" --target-org "* ]]; then
    targetOrg=${LBUFFER##* --target-org }
    targetOrg=${targetOrg%% *}
  fi

  # Show loading message
  echo "Loading test classes..."

  # Get package directories from sfdx-project.json
  local packageDirs=()
  if [[ -f sfdx-project.json ]]; then
    while IFS= read -r dir; do
      packageDirs+=("$dir")
    done < <(jq -r '.packageDirectories[].path' sfdx-project.json)
  fi

  # Find local test classes
  local localTests=()
  for dir in "${packageDirs[@]}"; do
    if [[ -d "$dir" ]]; then
      while IFS= read -r -d '' file; do
        localTests+=("$(basename "$file" .cls)")
      done < <(find "$dir" -name "*Test.cls" -print0)
    fi
  done

  # Query org for test classes
  local orgTests=()
  if [[ -n "$targetOrg" ]]; then
    if output=$(sf data query -q "select Name from ApexClass where Name like '%Test'" -o "$targetOrg" --json 2> /dev/null); then
      while IFS= read -r name; do
        orgTests+=("$name")
      done < <(echo "$output" | jq -r '.result.records[].Name' 2> /dev/null)
    fi
  else
    if output=$(sf data query -q "select Name from ApexClass where Name like '%Test'" --json 2> /dev/null); then
      while IFS= read -r name; do
        orgTests+=("$name")
      done < <(echo "$output" | jq -r '.result.records[].Name' 2> /dev/null)
    fi
  fi

  # Combine and unique
  local allTests=("${localTests[@]}" "${orgTests[@]}")
  local uniqueTests=()
  declare -A seen
  for test in "${allTests[@]}"; do
    if [[ -z "${seen[$test]}" ]]; then
      seen[$test]=1
      uniqueTests+=("$test")
    fi
  done

  # Select with fzf
  local selected=$(printf '%s\n' "${uniqueTests[@]}" | sort | $(__fzfcmd) -m -i --header="Select test classes (Tab to select multiple, Enter to confirm)")

  # Insert space separated
  if [[ -n "$selected" ]]; then
    selected="${selected//$'\n'/ }"
    LBUFFER="${LBUFFER:0:$CURSOR}$selected${LBUFFER:$CURSOR}"
    CURSOR=$((CURSOR + ${#selected}))
  fi

  zle reset-prompt
  return $?
}

zle -N fzf-test-classes{,}
bindkey "^t" fzf-test-classes
