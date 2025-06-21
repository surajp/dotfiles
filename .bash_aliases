#some history options since these will be common across all my setups
export HISTCONTROL=ignoreboth
export HISTTIMEFORMAT="%Y-%m-%d %T "
export HISTSIZE=100000

alias push='sfdx project:deploy:start'
alias pull='sfdx project:retrieve:start'
alias orgs='sfdx org:list --all --json --skip-connection-status'
alias isvim='env | grep -i vim'
alias graph='git log --all --graph --decorate --pretty=format:"%C(auto)%h %C(reset)%C(blue)%ad%C(reset) %C(auto)%d %s %C(cyan)<%an>%C(reset)" --date=format:"%Y-%m-%d %H:%M"'
alias gco='git checkout'
alias pmd="$PMD_HOME/bin/run.sh pmd"
alias jformat="java -jar $HOME/libs/google-java-format-1.9-all-deps.jar --replace"
alias fd='fdfind'

alias n='nvim .'
# you need 'fd-find' installed for the commands below
export FZF_DEFAULT_COMMAND="fd -H -t f --exclude={.git,node_modules}"
export FZF_ALT_C_COMMAND="fd -H -t d --exclude={.git,node_modules}"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

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

show_default_org() {
  if [ -f './.sfdx/sfdx-config.json' ]; then
    defaultusername="$(cat ./.sfdx/sfdx-config.json 2> /dev/null | jq -r '.defaultusername')"
    [[ "$defaultusername" = "null" ]] && defaultusername=""
    echo $defaultusername
  else
    echo ''
  fi
}

#Add sfdx default org to prompt
export PS1='\w $(show_default_org) \$ '

newclass() {
  if [ $# -eq 1 ]; then
    sfdx apex:generate:class -n $1 -d "force-app/main/default/classes"
  else
    echo "You need to specify a class name"
  fi
}

openr() {
  if [ $# -eq 1 ]; then
    sfdx org:open -r -o "$1" -p "/lightning/page/home"
  else
    sfdx org:open -r -p "/lightning/page/home"
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

	</LightningMessageChannel>" >> "force-app/main/default/messageChannels/$1.messageChannel-meta.xml"
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
if type nvim > /dev/null 2>&1; then
  alias vim='nvim'
fi

alias yeet="sfdx org:list --clean -p"

alias gentags='ctags --extra=+q --langmap=java:.cls.trigger -f ./tags -R */main/default/classes/'

alias refreshmdapi='curl -SL https://dx-extended-coverage.my.salesforce-sites.com/services/apexrest/report?version=64 -o ~/.mdapiReport.json'

alias sfrest="$PROJECTS_HOME/dotfiles/scripts/sfRestApi.sh"
alias sftrace="$PROJECTS_HOME/dotfiles/scripts/traceFlag.sh"

# update system date
alias syncdate="sudo ntpdate pool.ntp.org"

function failedResults() {
  if [[ $# -eq 1 ]]; then
    orgName=$(show_default_org)
    sfrest $orgName "/v58.0/jobs/ingest/$1/failedResults"
  else
    sfrest $1 "/v58.0/jobs/ingest/$2/failedResults"
  fi
}

function updateOrgTimeZone() {
  if [[ $# -eq 1 ]]; then
    node -e "console.log(\"update new User(Id=UserInfo.getUserId(),TimeZoneSidKey='\"+Intl.DateTimeFormat().resolvedOptions().timeZone+\"');\")" | sfdx apex:run -o "$1"
  else
    node -e "console.log(\"update new User(Id=UserInfo.getUserId(),TimeZoneSidKey='\"+Intl.DateTimeFormat().resolvedOptions().timeZone+\"');\")" | sfdx apex:run
  fi
}

alias xaa='exa -lhi --icons -snew'

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

#sessionzer
function tm() {
  if [[ $# -eq 1 ]]; then
    selected=$1
  else
    selected=$(find ~/projects -mindepth 1 -maxdepth 1 -type d | fzf)
  fi

  if [[ -z $selected ]]; then
    exit 0
  fi

  selected_name=$(basename "$selected" | tr . _)
  tmux_running=$(pgrep tmux)

  if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected_name -c $selected
    exit 0
  fi

  if tmux has-session -t=$selected_name 2> /dev/null; then
    if [[ -z $TMUX ]]; then
      tmux attach -t $selected_name
    else
      tmux switch-client -t $selected_name
    fi
  else
    tmux new-session -ds $selected_name -c $selected
    tmux switch-client -t $selected_name
  fi

}

alias ..='nvim .'

fixbrokensfdeps() {
  rm -rf node_modules 2> /dev/null
  rm -f package-lock.json 2> /dev/null

  npm install -D \
    eslint@^9.0.0 \
    @lwc/eslint-plugin-lwc@^3.0.0 \
    @salesforce/eslint-config-lwc@^4.0.0 \
    @salesforce/eslint-plugin-lightning@^2.0.0 \
    eslint-plugin-jest@^28.11.1 \
    @salesforce/eslint-plugin-aura@^3.0.0

  curl -sSL \
    "https://gist.githubusercontent.com/surajp/17f8a581a90f1c238ec9a92bf771f52c/raw/8e48d98cf7419c005746c1754aac0187959d5012/eslint-config.js" \
    -o eslint.config.js
}
