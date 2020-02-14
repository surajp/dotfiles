
alias push='sfdx force:source:push'
alias pull='sfdx force:source:pull' 
alias orgs='sfdx force:org:list --all' 
alias isvim='env | grep -i vim'

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

open() {
	if [ $# -eq 1 ]
	then
		sfdx force:org:open -u "$1" -p "/lightning/page/home"
	else
		sfdx force:org:open -p "/lightning/page/home"
	fi
}

createo() {
	if [ $# -eq 1 ]
	then
		sfdx force:org:create -s -f config/project-scratch-def.json -d 20 -w 5 -a "$1"
	else
		sfdx force:org:create -s -f config/project-scratch-def.json -d 20 -w 5 
	fi
}

squery() {
	if [ $# -eq 1 ]
	then
		sfdx force:data:soql:query -q "$1"
	elif [ $# -eq 2 ]
	then
		sfdx force:data:soql:query -q "$1" -u $2
	fi
}

createchannel(){
	if [ $# -eq 1 ]
	then
	echo "<?xml version="1.0" encoding="UTF-8"?>
	<LightningMessageChannel xmlns="http://soap.sforce.com/2006/04/metadata">
		<masterLabel>$1</masterLabel>
		<isExposed>true</isExposed>
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
