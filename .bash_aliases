
alias push='sfdx force:source:push'
alias pull='sfdx force:source:pull' 
alias orgs='sfdx force:org:list --all' 

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
alias orgs='sfdx force:org:list --all'
