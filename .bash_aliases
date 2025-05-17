#some history options since these will be common across all my setups
export HISTCONTROL=ignoreboth
export HISTTIMEFORMAT="%Y-%m-%d %T "
export HISTSIZE=100000
export BAT_THEME=Dracula
export SF_SINGLE_USE_ORG_OPEN_URL=true

alias .='nvim .'
alias push='sfdx project:deploy:start'
alias pull='sfdx project:retrieve:start'
alias orgs="sfdx org:list --all --skip-connection-status --json | jq '{ result: ( .result | map_values(map({username,alias,instanceUrl})) ) }'"
alias isvim='env | grep -i vim'
alias graph='git log --all --graph --decorate --pretty=format:"%C(auto)%h %C(reset)%C(blue)%ad%C(reset) %C(auto)%d %s %C(cyan)<%an>%C(reset)" --date=format:"%Y-%m-%d %H:%M"'
alias gco='git checkout'
alias jformat="java -jar $HOME/libs/google-java-format-1.9-all-deps.jar --replace"
# alias fd='fdfind'

#docker compose
alias dc="docker compose"
alias dcu="docker compose up"
alias dcd="docker compose down"

alias pdm=podman
# you need 'fd-find' installed for the commands below
export FZF_DEFAULT_COMMAND="fd -t f --exclude={.git,node_modules}"
export FZF_ALT_C_COMMAND="fd -t d --exclude={.git,node_modules}"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_DEFAULT_OPTS='--height "80%" --preview "if [ -d {} ];then eza -lhi --icons -snew {};elif [ -f {} ];then bat --color=always {};else echo {};fi" --preview-window "right:60%:wrap"'

#Setup forgit, if installed
if [[ -d $PROJECTS_HOME/forgit ]]; then
	export FORGIT_FZF_DEFAULT_OPTS="
    --exact
    --border
    --cycle
    --reverse
    --height '80%'
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

# show_default_org() {
# 	if [ -f './.sfdx/sfdx-config.json' ]; then
# 		defaultusername="$(cat ./.sfdx/sfdx-config.json 2>/dev/null | jq -r '.defaultusername')"
# 		[[ "$defaultusername" = "null" ]] && defaultusername="" #if defaultusername is null set it to empty string
# 		export DEFAULT_SF_ORG=$defaultusername
# 	else
# 		export DEFAULT_SF_ORG=
# 	fi
# }

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
  local command="sfdx org:open -r --json"
  if [[ $# -ge 1 && "$1" != "default" ]]; then
    command=$command" --target-org $1"
  fi
  if [ $# -eq 2 ]; then
    command=$command" --path \"$2\""
  fi
  local result=$(eval "$command")
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
		sfdx org:create:scratch -d -f config/project-scratch-def.json -y 20 -w 5 -a "$1"
	else
		sfdx org:create:scratch -d -f config/project-scratch-def.json -y 20 -w 5
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

alias refreshmdapi='wget "https://dx-extended-coverage.my.salesforce-sites.com/services/apexrest/report?version=65" && mv report?version=64 ~/.mdapiReport.json'

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

# delete apex logs fast
function dellogs() {
    if [ $# -eq 1 ]; then
      if [ "$1" = "-h" ]; then
	echo "Usage: dellogs <orgName>"
	return 1
      fi
      sfdx data:query -q "select id from apexlog" -r csv -o "$1" | awk 'NR>1' | xargs -n5 | sed 's/ /,/g' | xargs -I {} -P 5 sh -c "sfdx api:request:rest --method DELETE --target-org \"$1\" \"services/data/v62.0/composite/sobjects?ids={}&allOrNone=false\" --body '{\"mode\":\"raw\"}'"
    else
      sfdx data:query -q "select id from apexlog" -r csv | awk 'NR>1' | xargs -n5 | sed 's/ /,/g' | xargs -I {} -P 5 sh -c "sfdx api:request:rest --method DELETE --target-org \"services/data/v62.0/composite/sobjects?ids={}&allOrNone=false\" --body '{\"mode\":\"raw\"}'"
    fi
}

# delete all obsolete flow versions except the latest version
function delflows() {
    if [ $# -eq 0 ]; then
      echo "Usage: delflows <flowName> [orgName]"
      return 1
    fi
    local flowName=$1
    if [ $# -eq 2 ]; then
      sfdx data:query -q "select id from flow where definition.developername='"$flowName"' and status='Obsolete' and Id not in (Select LatestVersionId from FlowDefinition where DeveloperName='"$flowName"')" -t -r csv -o "$2" | awk 'NR>1' | xargs -n1 | sed 's/ /,/g' | xargs -I {} -P 5 sh -c "sfdx api:request:rest --method DELETE --target-org \"$2\" \"services/data/v62.0/tooling/sobjects/Flow/{}\" --body '{\"mode\":\"raw\"}'"
    else
      sfdx data:query -q "select id from flow where definition.developername='"$flowName"' and status='Obsolete' and Id not in (Select LatestVersionId from FlowDefinition where DeveloperName='"$flowName"')" -t -r csv | awk 'NR>1' | xargs -n1 | sed 's/ /,/g' | xargs -I {} -P 5 sh -c "sfdx api:request:rest --method DELETE --target-org \"services/data/v62.0/tooling/sobjects/Flow/{}\" --body '{\"mode\":\"raw\"}'"
    fi
}

function _getDefaultOrgName() {
  local orgName=$(sfdx config:get target-org --json | jq -r '.result[0].value')
  echo "$orgName"
}

function downloadEventLogFiles(){
  local usage=' Download all event log files from a Salesforce org. The output will be stored in an "eventLogFiles" folder in the current directory.\n The orgName is optional. If not provided, the default org will be used.\n Usage: downloadEventLogs <orgName>' 
  if [ $# -eq 1 ] && [ "$1" = "-h" ]; then
    echo "$usage"
    return 1
  fi
  local orgName=$(_getDefaultOrgName)
  if [ $# -eq 1 ]; then
    orgName="$1"
  fi
  if [ ! -d eventLogFiles ]; then
    mkdir eventLogFiles
  fi
  sfdx data:query -q "SELECT Id, EventType, LogFile FROM EventLogFile" -r json -o "$orgName" > /tmp/eventlogfiles.json
  jq -r '.result.records[] | .EventType+"_"+.LogFile' /tmp/eventlogfiles.json | xargs -n 1 -I {} -P 5 sh -c 'var={};type=${var%_*};url=${var##*_};sfdx api:request:rest -o '"$orgName"' $url > eventLogFiles/eventlogdetails_$type.csv'
  rm /tmp/eventlogfiles.json
}

# reddit analysis
function pullFromReddit() {
    local usage='Pulls the latest reddit posts from a given subreddit and returns the results. \n Usage: pullFromReddit <subreddit>'
    if [ $# -eq 1 ] && [ "$1" = "-h" ]; then
      echo "$usage"
      return 1
    fi
    local subreddit=${1:-all}
    local retval=$(curl -sSL "https://www.reddit.com/r/$subreddit/.json?limit=40" -A my-reddit-bot-qq | jq '.data.children[].data | {title: .title, selftext: .selftext, subreddit: .subreddit,created: .created_utc, author: .author}') 
    echo "$retval"
}

function searchReddit() {
    local usage='Searches reddit posts for a given search term and returns the results. \n Usage: searchReddit <subreddit>'
    if [ $# -eq 1 ] && [ "$1" = "-h" ]; then
      echo "$usage"
      return 1
    fi
    local searchterm=${1:-news}
    # url encode the search term
    searchterm=$(echo "$searchterm" | jq -sRr @uri)
    local retval=$(curl -sSL "https://www.reddit.com/search/.json?q=$searchterm&limit=40" -A my-reddit-bot-qq | jq '.data.children[].data | {title: .title, selftext: .selftext,  subreddit: .subreddit,created: .created_utc, author: .author}') 
    echo "$retval"
}

# install vertex common connected app into an org
function installConnectedApp() {
  local usage='Generates a url to install the Vertex Common connected app into a Salesforce org, and copies it to the clipboard. All params are optional. If orgname is not provided, the default org will be used as the installation target. if app id and app org id are provided those ids will be used instead of vertexs default ids. \n Usage: installConnectedApp <orgName> <app_id> <app_org_id>'
  if [ $# -eq 1 ] && [ "$1" = "-h" ]; then
    echo "$usage"
    return 1
  fi
   local orgName=${1:_getDefaultOrgName}
   local app_id=${2:-0Ci6S000000kAxU}
   local app_org_id=${3:-00Di0000000frx9}
   local openPath="/identity/app/AppInstallApprovalPage.apexp?app_id=$app_id&app_org_id=$app_org_id"
   export PATH=$PATH
   if [ $# -gt 0 ]; then
     openr "$1" "$openPath"
   else
     openr "default" "$openPath"
   fi
}

#Get host ip address in WSL
hostip() {
  cat /etc/resolv.conf | grep nameserver | cut -d' ' -f 2
}


#Convert keyring to apt format
function gpgconv() {
  if [ $# -eq 0 ]; then
    echo "Usage: gpgconv <keyfile>"
    return 1
  fi
  gpg --no-default-keyring --keyring ./temp-keyring.gpg --import "$1"
  gpg --no-default-keyring --keyring ./temp-keyring.gpg --export --output "$1.converted.gpg"
  rm ./temp-keyring.gpg
}

#start echo server
# alias localhost="node $HOME/libs/echo.js"

alias tm="$PROJECTS_HOME/dotfiles/tmux-sessionizer.sh"

#for macos
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
alias madness='echo "starting server on port 5989 (http://md.localhost)" && sleep 3 && podman run --rm -it -v $PWD:/docs -p 5989:3000 dannyben/madness server'
alias fixsfdeps='rm -rf node_modules 2>/dev/null && rm -f package-lock.json 2>/dev/null && npm install eslint@^9.0.0 @lwc/eslint-plugin-lwc@^3.0.0 @salesforce/eslint-config-lwc@^4.0.0 @salesforce/eslint-plugin-lightning@^2.0.0 eslint-plugin-jest@^28.11.1 @salesforce/eslint-plugin-aura@^3.0.0 -D && curl -sSL https://gist.githubusercontent.com/surajp/17f8a581a90f1c238ec9a92bf771f52c/raw/8e48d98cf7419c005746c1754aac0187959d5012/eslint-config.js -o eslint.config.js'

alias postmanode='node $HOME/projects/node-postman-server/server.mjs'

alias makecert='sh $HOME/projects/dotfiles/scripts/makecert.sh'
alias pdm=podman
alias jjj="jj log -r '@ | ancestors(remote_bookmarks().., 2) | trunk()'"
