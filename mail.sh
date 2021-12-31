#!/bin/bash

##################################################################
# this is a cli tool to set-up and login to protonmail with mutt #
# deps:                                                          #
# -hydroxide                                                     #
# -offlineimap                                                   #
##################################################################

# confs and paths
omaprc=$HOME/.offlineimaprc
muttrc=$HOME/.muttrc

usage() {
	printf "\nUSAGE: $0 [-h <HELP>] [-u <USERNAME>]"
	echo ""
}

if [[ ${#} -eq 0 ]]; then
	usage
	exit 1
fi

do_stuff() {
	echo "stuff being done"
}

while getopts ":h:e:u:" o; do
	case "${o}" in
		h) echo "This is the help" ;;
		e) do_stuff ;;
		u)
			u=${OPTARG}
			;;
		*)
			echo "Invalid option: -${OPTARG}."
			usage
			;;
	esac
done

# kill stuff
pkill -9 hydroxide
pkill -9 offlineimap

# authenticate
hydroxide auth $u@protonmail.com >> /tmp/$$
echo "Getting temporary password ..."
# bridge password
bp=`cat /tmp/$$ | awk '{print $3}'`
bp_escaped=$(echo $bp| sed 's/\//\\\//g')
#echo $bp
rm /tmp/$$
echo "Updating mutt configuration ..."
sed -i "s/set imap_pass =.*/set imap_pass = $bp_escaped/g" $muttrc
echo "Updating offlinemap configuration ..."
sed -i "s/remotepass =.*/remotepass = $bp_escaped/g" $omaprc
# start things
hydroxide imap &
sleep 1
offlineimap
#mutt
