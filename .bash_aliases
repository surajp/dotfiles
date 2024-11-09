#some history options since these will be common across all my setups
export HISTCONTROL=ignoreboth
export HISTTIMEFORMAT="%Y-%m-%d %T "
export HISTSIZE=100000
export BAT_THEME=Dracula

alias .='nvim .'
alias push='sfdx project:deploy:start'
alias pull='sfdx project:retrieve:start'
alias orgs='sfdx org:list --all --skip-connection-status'
alias isvim='env | grep -i vim'
alias graph='git log --all --graph --decorate --pretty=format:"%C(auto)%h %C(reset)%C(blue)%ad%C(reset) %C(auto)%d %s %C(cyan)<%an>%C(reset)" --date=format:"%Y-%m-%d %H:%M"'
alias gco='git checkout'
alias pmd="$PMD_HOME/bin/run.sh pmd"
alias jformat="java -jar $HOME/libs/google-java-format-1.9-all-deps.jar --replace"
# alias fd='fdfind'

#docker compose
alias dc="docker compose"
alias dcu="docker compose up"
alias dcd="docker compose down"

# you need 'fd-find' installed for the commands below
export FZF_DEFAULT_COMMAND="fd -t f --exclude={.git,node_modules}"
export FZF_ALT_C_COMMAND="fd -t d --exclude={.git,node_modules}"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_DEFAULT_OPTS='--height "80%" --preview "if [ -d {} ];then exa -lhi --icons -snew {};elif [ -f {} ];then bat --color=always {};else echo {};fi" --preview-window "right:60%:wrap"'

#Setup forgit, if installed
if [[ -d $PROJECTS_HOME/forgit ]]; then
	export FORGIT_FZF_DEFAULT_OPTS="
    --exact
    --border
    --cycle
    --reverse
    --height '80%'
    "
	source $PROJECTS_HOME/forgit/forgit.plugin.sh
fi

#Clipboard functions
source ~/.clipfunctions.rc

show_default_org() {
	if [ -f './.sfdx/sfdx-config.json' ]; then
		defaultusername="$(cat ./.sfdx/sfdx-config.json 2>/dev/null | jq -r '.defaultusername')"
		[[ "$defaultusername" = "null" ]] && defaultusername="" #if defaultusername is null set it to empty string
		export DEFAULT_SF_ORG=$defaultusername
	else
		export DEFAULT_SF_ORG=
	fi
}

# Check if show_default_org is not already in the precmd_functions array. This is to evaluate show_default_org before every prompt
if [[ -z "${precmd_functions[(Ie)show_default_org]}" ]]; then
  # Add show_default_org to precmd_functions if it's not there
  precmd_functions+=(show_default_org)
fi

#Add sfdx default org to prompt
export PS1='%1~ $DEFAULT_SF_ORG \$ '

newclass() {
	if [ $# -eq 1 ]; then
		sfdx apex:generate:class -n $1 -d "force-app/main/default/classes"
	else
		echo "You need to specify a class name"
	fi
}

openr() {
	if [ $# -eq 1 ]; then
		result=$(sfdx org:open -r -o "$1" -p "/lightning/page/home" --json)
	else
		result=$(sfdx org:open -r -p "/lightning/page/home" --json)
	fi
	local exitcode=$(jq -r '.status' <<< "$result")
	if [ $? -eq 0 ] && [ "$exitcode" = "0" ]; then
    jq -r '.result.url' <<< "$result" | tcopy
	  echo "URL copied to clipboard"
  else
    echo "$result"
  fi
}

openo() {
	if [ $# -eq 1 ]; then
		sfdx org:open -u "$1" -p "/lightning/page/home"
	else
		sfdx org:open -p "/lightning/page/home"
	fi
}

#alias open=openo # bash won't let me create a function called `open`

neworg() {
	if [ $# -eq 1 ]; then
		sfdx org:create -s -f config/project-scratch-def.json -d 20 -w 5 -a "$1"
	else
		sfdx org:create -s -f config/project-scratch-def.json -d 20 -w 5
	fi
}

alias squery='sfdx data:query -q "$1"'

createchannel() {
	if [ $# -eq 1 ]; then
		echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
	<LightningMessageChannel xmlns=\"http://soap.sforce.com/2006/04/metadata\">
		<masterLabel>$1</masterLabel>
		<isExposed>false</isExposed>
		<description>This is a sample Lightning Message Channel.</description>

		<lightningMessageFields>
		  <fieldName>messageToSend</fieldName>
			<description>message To Send</description>
	 	</lightningMessageFields>

	</LightningMessageChannel>" >>"force-app/main/default/messageChannels/$1.messageChannel-meta.xml"
	else
		echo "Message Channel name is required to be specified"
	fi
}

createlwc() {
	if [ $# -eq 1 ]; then
		sfdx lightning:generate:component --type lwc -d force-app/main/default/lwc -n "$1"
	else
		echo "LWC name is required"
	fi
}

createaura() {
	if [ $# -eq 1 ]; then
		sfdx force:lightning:component:create --type aura -d force-app/main/default/aura -n "$1"
	else
		echo "Component name is required"
	fi
}

alias python=python3
if type nvim >/dev/null 2>&1; then
	alias vim='nvim'
fi

alias yeet="sfdx org:list --clean -p"

alias gentags='/opt/homebrew/bin/ctags --extras=+q --langmap=java:.cls.trigger -f ./tags -R **/main/default/classes/**'

alias refreshmdapi='wget "https://mdcoverage.secure.force.com/services/apexrest/report?version=61" && mv report?version=60 ~/.mdapiReport.json'

alias sfrest="$PROJECTS_HOME/dotfiles/scripts/sfRestApi.sh"
alias sftrace="$PROJECTS_HOME/dotfiles/scripts/traceFlag.sh"

# update system date
alias syncdate="sudo ntpdate pool.ntp.org"

function failedResults() {
	if [[ $# -eq 1 ]]; then
	  if [[ "$1" == "-h" ]]; then
	    echo "Usage: failedResults <jobId> [orgName]"
	  else
		  orgName=$(show_default_org)
		  sfrest $orgName "/data/v61.0/jobs/ingest/$1/failedResults"
		fi
	else
		sfrest $2 "/data/v61.0/jobs/ingest/$1/failedResults"
	fi
}

function updateOrgTimeZone() {
	if [[ $# -eq 1 ]]; then
		node -e "console.log(\"update new User(Id=UserInfo.getUserId(),TimeZoneSidKey='\"+Intl.DateTimeFormat().resolvedOptions().timeZone+\"');\")" | sfdx force:apex:execute -u "$1"
	else
		node -e "console.log(\"update new User(Id=UserInfo.getUserId(),TimeZoneSidKey='\"+Intl.DateTimeFormat().resolvedOptions().timeZone+\"');\")" | sfdx force:apex:execute
	fi
}

alias xaa='eza -lhi --icons -snew'

#clear source tracking
function ctrack() {
	if [ $# -eq 1 ]; then
		sfdx project:delete:tracking -p -u "$1" && sfdx project:reset:tracking -p -u "$1"
	else
		sfdx project:delete:tracking -p && sfdx project:reset:tracking -p
	fi
}

#Get host ip address in WSL
hostip() {
	cat /etc/resolv.conf | grep nameserver | cut -d' ' -f 2
}


#Convert keyring to apt format
function gpgconv() {
	gpg --no-default-keyring --keyring ./temp-keyring.gpg --import "$1"
	gpg --no-default-keyring --keyring ./temp-keyring.gpg --export --output "$1.converted.gpg"
	rm ./temp-keyring.gpg
}

#start echo server
alias localhost="node $HOME/libs/echo.js"

alias tm="$PROJECTS_HOME/dotfiles/tmux-sessionizer.sh"
alias flushdns="sudo dscacheutil -flushcache;sudo killall -HUP mDNSResponder"

# local notification
ntfy() {
  local message
  local topic
  if [ $# -eq 0 ]; then
    if [ ! -p /dev/stdin ]; then
	echo "Usage: ntfy <message> [topic]"
	return 1
    fi
    message=$(cat /dev/stdin)
    topic="test"
    elif [ $# -eq 1 ]; then
      if [ ! -p /dev/stdin ]; then
      	message=$1
      	topic="test"
      	else
      	  message=$(cat /dev/stdin)
      	  topic=$1
      fi
    else
      message=$1
      topic=$2
  fi
  curl -d "$message" "https://ntfy.mylab.icu/$topic"
}

alias ksh='kitten ssh'
alias madness='docker run --rm -it -v $PWD:/docs -p 3000:3000 dannyben/madness'
