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
__fzf_select__() {
	local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | cut -b3-"}"
	eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --preview='less {}' --reverse --bind=ctrl-z:ignore,alt-up:preview-page-up,alt-down:preview-page-down $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read -r item; do
		printf '%q ' "$item"
	done
	echo
}

if [[ $- =~ i ]]; then

	declare -A commandsmap
	commandsmap=(
		["heroku"]="$HOME/.herokucommands.json"
		["sfdx"]="$HOME/.sfdxcommands.json"
		["sf"]="$HOME/.sfcommands.json"
	)

	__fzfcmd() {
		[ -n "$TMUX_PANE" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "$FZF_TMUX_OPTS" ]; } &&
			echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
	}

	fzf-file-widget() {
		local selected="$(__fzf_select__)"
		READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
		READLINE_POINT=$((READLINE_POINT + ${#selected}))
	}

	__fzf_cd__() {
		local cmd dir
		cmd="${FZF_ALT_C_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | cut -b3-"}"
		dir=$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS" $(__fzfcmd) +m) && printf 'cd %q' "$dir"
	}

	__fzf_history__() {
		local output
		output=$(
			builtin fc -lnr -2147483648 |
				last_hist=$(HISTTIMEFORMAT='' builtin history 1) perl -n -l0 -e 'BEGIN { getc; $/ = "\n\t"; $HISTCMD = $ENV{last_hist} + 1 } s/^[ *]//; print $HISTCMD - $. . "\t$_" if !$seen{$_}++' |
				FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort,ctrl-z:ignore $FZF_CTRL_R_OPTS +m --read0" $(__fzfcmd) --query "$READLINE_LINE"
		) || return
		READLINE_LINE=${output#*$'\t'}
		if [ -z "$READLINE_POINT" ]; then
			echo "$READLINE_LINE"
		else
			READLINE_POINT=0x7fffffff
		fi
	}

	fzf-emojis() {
		selectedSmiley="$(cat ~/.emojis.txt | $(__fzfcmd) | cut --fields=1 --delimiter=' ')"
		READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selectedSmiley${READLINE_LINE:$READLINE_POINT}"
		READLINE_POINT=$((READLINE_POINT + ${#selectedSmiley}))
	}

	fzf-soql() {
		local linethusfar="${READLINE_LINE:0:$READLINE_POINT}"
		local query="$(echo ${linethusfar%* } | awk -F '[ ,.]' '{print $NF}')"
		if [[ -f "./schema.txt" ]]; then
			if [[ "$linethusfar" != *" " && "$linethusfar" != *"." && "$linethusfar" != *"," ]]; then
				local selected="$(cat ./schema.txt | $(__fzfcmd) -m -i --query $query | awk -F ' ' '{printf $1","}')"
				local tempReadPoint=$((READLINE_POINT - ${#query}))
				READLINE_LINE="${READLINE_LINE:0:$tempReadPoint}${READLINE_LINE:$READLINE_POINT}"
				READLINE_POINT=$tempReadPoint
			elif [[ "$query" = "from" && -f "./objects.txt" ]]; then
				local selected="$(cat ./objects.txt | $(__fzfcmd) -i)"
			else
				local selected="$(cat ./schema.txt | $(__fzfcmd) -m -i | awk -F ' ' '{printf $1","}')"
			fi
			READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
			READLINE_POINT=$((READLINE_POINT + ${#selected}))
		fi
	}

	fzf-sfdx-alias() {
		local selected="$(cat ~/.sfdxaliases | $(__fzfcmd) | awk -v i=1 '{while(i++<=NF){if(match($i,"@")){print $i;break}}}')"
		READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
		READLINE_POINT=$((READLINE_POINT + ${#selected}))
	}

	fzf-sfdx-mdapiTypes() {
		local selected="$(jq -r '.types | to_entries[] | select (.value.metadataApi=true).key' ~/.mdapiReport.json | $(__fzfcmd) -i)"
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
		subcmd=$(echo "${fullcmd#$cmd}" | awk -F "-" '{print $1}' | awk '{$1=$1};1')
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

	# Required to refresh the prompt after fzf
	bind -m emacs-standard '"\er": redraw-current-line'

	bind -m vi-command '"\C-z": emacs-editing-mode'
	bind -m vi-insert '"\C-z": emacs-editing-mode'
	bind -m emacs-standard '"\C-z": vi-editing-mode'

	if ((BASH_VERSINFO[0] < 4)); then
		# CTRL-T - Paste the selected file path into the command line
		bind -m emacs-standard '"\C-t": " \C-b\C-k \C-u`__fzf_select__`\e\C-e\er\C-a\C-y\C-h\C-e\e \C-y\ey\C-x\C-x\C-f"'
		bind -m vi-command '"\C-t": "\C-z\C-t\C-z"'
		bind -m vi-insert '"\C-t": "\C-z\C-t\C-z"'

		# CTRL-R - Paste the selected command from history into the command line
		bind -m emacs-standard '"\C-r": "\C-e \C-u\C-y\ey\C-u"$(__fzf_history__)"\e\C-e\er"'
		bind -m vi-command '"\C-r": "\C-z\C-r\C-z"'
		bind -m vi-insert '"\C-r": "\C-z\C-r\C-z"'
	else
		# CTRL-T - Paste the selected file path into the command line
		bind -m emacs-standard -x '"\C-f": fzf-file-widget'
		bind -m vi-command -x '"\C-f": fzf-file-widget'
		bind -m vi-insert -x '"\C-f": fzf-file-widget'

		# CTRL-R - Paste the selected command from history into the command line
		bind -m emacs-standard -x '"\C-r": __fzf_history__'
		bind -m vi-command -x '"\C-r": __fzf_history__'
		bind -m vi-insert -x '"\C-r": __fzf_history__'

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
		bind -m emacs-standard -x '"\C-_": fzf-sfdx-mdapiTypes'
		bind -m vi-command -x '"\C-_": fzf-sfdx-mdapiTypes'
		bind -m vi-insert -x '"\C-_": fzf-sfdx-mdapiTypes'

	fi

	# ALT-C - cd into the selected directory
	bind -m emacs-standard '"\ec": " \C-b\C-k \C-u`__fzf_cd__`\e\C-e\er\C-m\C-y\C-h\e \C-y\ey\C-x\C-x\C-d"'
	bind -m vi-command '"\ec": "\C-z\ec\C-z"'
	bind -m vi-insert '"\ec": "\C-z\ec\C-z"'

fi

source ~/fzf-extras.bash
