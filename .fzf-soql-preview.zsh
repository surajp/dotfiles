#!/bin/zsh
__fzf_soql_preview() {
  local objectName="${1%%.*}"
  local fieldName="${1#*.}"
  local orgId="${2:-default}"
  local orgDir="$HOME/.sobjtypes/$orgId/customFields"
  [[ ! -d "$orgDir" ]] && mkdir -p "$orgDir"
  local objectFieldsFile="$orgDir/${objectName}.json"

  if [[ -f "$objectFieldsFile" && "$(cat $objectFieldsFile)" != "" ]]; then
    jq -r --arg field "$fieldName" '.result.fields[] | select(.name == $field) | [
      "Field: " + .name,
      "Type: " + .type,
      "Label: " + .label,
      "Length: " + (.length // "N/A" | tostring),
      "Required: " + (.nillable | not | tostring),
      "Description: " + (.inlineHelpText // "N/A"),
      "Picklist Values: " + (if .picklistValues then (.picklistValues | map(.value) | join(", ")) else "N/A" end),
      "Reference To: " + (if .referenceTo then (.referenceTo | join(", ")) else "N/A" end),
      "Formula: " + (.calculatedFormula | tostring),
      "IdLookup: " + (.idLookup | tostring)
    ][]' "$objectFieldsFile" 2> /dev/null
  else
    local targetOrgFlag=""
    if [[ "$orgId" != "default" ]]; then
      sfdx sobject:describe --sobject "$objectName" --json $targetOrgFlag > $objectFieldsFile
    else
      sfdx sobject:describe --sobject "$objectName" --json > $objectFieldsFile
    fi

    if [[ $? -ne 0 ]]; then
      echo "Error retrieving object description for $objectName"
      return 1
    fi
    jq -r --arg field "$fieldName" '.result.fields[] | select(.name == $field) | [
      "Field: " + .name,
      "Type: " + .type,
      "Label: " + .label,
      "Length: " + (.length // "N/A" | tostring),
      "Required: " + (.nillable | not | tostring),
      "Description: " + (.inlineHelpText // "N/A"),
      "Picklist Values: " + (if .picklistValues then (.picklistValues | map(.value) | join(", ")) else "N/A" end),
      "Reference To: " + (if .referenceTo then (.referenceTo | join(", ")) else "N/A" end),
      "Formula: " + (.calculatedFormula | tostring),
      "IdLookup: " + (.idLookup | tostring)
    ][]' "$objectFieldsFile" 2> /dev/null || echo "Field information not available"
  fi
}

__fzf_soql_preview "$@"
