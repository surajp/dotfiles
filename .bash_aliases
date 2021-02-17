alias push='sfdx force:source:push'
alias pull='sfdx force:source:pull' 
alias orgs='sfdx force:org:list --all' 
alias isvim='env | grep -i vim'
alias graph='git log --graph --all --decorate --oneline'
alias gco='git checkout'
alias pmd="$HOME/softwares/pmd-bin-6.30.0/bin/run.sh pmd"
alias jformat="java -jar $HOME/libs/google-java-format-1.9-all-deps.jar --replace"

show_default_org(){
  if [ -f './.sfdx/sfdx-config.json' ]
  then
    cat ./.sfdx/sfdx-config.json 2>/dev/null | jq -r '.defaultusername'
  else
    echo ''
  fi
}

#Add sfdx default org to prompt
export PS1="\w $(show_default_org) \$ "


newclass(){
	if [ $# -eq 1 ]
	then
		sfdx force:apex:class:create -n $1 -d "force-app/main/default/classes"
	else
		echo "You need to specify a class name" 
	fi
}

openr() {
	if [ $# -eq 1 ]
	then
		sfdx force:org:open -r -u "$1" -p "/lightning/page/home"
	else
		sfdx force:org:open -r -p "/lightning/page/home"
	fi
}

alias open='sfdx force:org:open -p "/lightning/page/home" -u '

alias createo='sfdx force:org:create -s -f config/project-scratch-def.json -d 20 -w 5 -a "$1"'

alias squery='sfdx force:data:soql:query -q "$1"'

createchannel(){
	if [ $# -eq 1 ]
	then
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

createlwc(){
	if [ $# -eq 1 ]
	then
		sfdx force:lightning:component:create --type lwc -d force-app/main/default/lwc -n "$1"
	else
		echo "LWC name is required"
	fi
}

createaura(){
	if [ $# -eq 1 ]
	then
		sfdx force:lightning:component:create --type aura -d force-app/main/default/aura -n "$1"
	else
		echo "Component name is required"
	fi
}


alias orgs='sfdx force:org:list --all'
alias python=python3
if type nvim > /dev/null 2>&1; then
	alias vim='nvim'
fi

alias deleteexpiredscratchorgs="sfdx force:org:list --all --json | jq '.result.scratchOrgs[] | select (.isExpired==true) | .username' | xargs -I % sh -c 'sfdx force:org:delete -u % -p'"

alias gentags='ctags --extra=+q --langmap=java:.cls.trigger -f ./tags -R force-app/main/default/classes/'

alias refreshmdapi='wget https://mdcoverage.secure.force.com/services/apexrest/report?version=51 && mv report?version=51 ~/.mdapiReport.json'
