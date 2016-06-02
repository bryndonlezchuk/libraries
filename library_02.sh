#!/bin/bash

#function library v2.0	May 31, 2016
#Bryndon Lezchuk (bryndonlezchuk@gmail.com)


#Global variables
INTERACTIVE="ON"
VERBOSE="OFF"
LOGFILE="OFF"
RECURSIVE="OFF"


#Generic setup function
#Sets global variables IFS, IFSTEMP, RUNDIR
#Calls getargs to assign arguments to global array ARGS
#	-d: creates given amount of temporary directories
#	-f: creates given amount of temporary files
setup () {
	local OPTIND
	local OPT
	while getopts ":d:f:" OPT; do
		case "$OPT" in
			#directory
			d)	mktempdir "$OPT";;
			#file
			f)	mktempfile "$OPT";;
			#other
			\?)	echo "Unkown option for function setup"
				cleanup 1;;
		esac
	done
	shift $(($OPTIND-1))


	IFSTEMP="$IFS"
	IFS=$' \n\t'
	getargs "$@"
	RUNDIR="$(pwd)"
}

#Cleanup function
#Remove any temporary directories and/or files
#Exit script
cleanup () {
	local EXIT="$1"

	IFS="$IFSTEMP"
	cd "$RUNDIR"

	#Remove temp directories
	for ITEM in "${TMPDIR[@]}"
	do
		rm -Rf "$ITEM"
		verbout "Removing directory '$ITEM' and all contents" "purple"
	done

	#Remove temp files
	for ITEM in "${TMPFILE[@]}"
	do
		rm -f "$ITEM"
		verbout "Removing file '$ITEM'" "purple"
	done

	verbout "Exiting program" "red"

	if [[ -z "$EXIT" ]]
	then
		exit 0
	elif [[ "$EXIT" =~ ^[[:digit:]]+$ ]]
	then
		exit "$EXIT"
	else	
		exit 1
	fi
}

#Assigns all script argumenents to global array ARGS
#	$@ is all arguments the script should proccess
getargs () {
	local I=0
	for ITEM in "$@"
	do
		debugout "ARGS[$I]=$ITEM" "yellow"
		ARGS[$I]="$ITEM"
		((I++))
	done
}










mktempdir () {
	#need code to handle adding to already existing array
	#add custom dir naming?

	local ARG="$1"
	if [[ "$ARG" =~ ^[[:digit:]]+$ &&  "$ARG" -gt 0 ]]
	then
		for ((i=${#TMPDIR[@]}; i<$ARG+${#TMPDIR[@]}; i++))
		do
			TMPDIR[$i]="$(mktemp -d)"
			verbout "TMPDIR[$i]=${TMPDIR[$i]}" "green"
		done
	fi
}

mktempfile () {
	#need code to handle adding to already existing array
	#add custom file naming?

	local ARG="$1"
	if [[ "$ARG" =~ ^[[:digit:]]+$ && "$ARG" -gt 0 ]]
		then
		for ((i=${#TMPFILE[@]}; i<$ARG+${#TMPFILE[@]}; i++))
		do
			TMPFILE[$i]=$(mktemp)
			verbout "TMPFILE[$i]=${TMPFILE[$i]}" "green"
		done
	fi
}











#Displays output to screen
#	$1 is the message to display
#	$2 (optional) is the color to display the message as
message () {
	local MSG="$1"
	local COLOR="$2"
	if [[ -z "$COLOR" ]]
	then
		echo "$MSG"
	else
		cmessage "$MSG" "$COLOR"
	fi
}

#Same as message, just displayed in-line
imessage () {
	local MSG="$1"
	local COLOR="$2"
	if [[ -z "$COLOR" ]]
	then
		echo -e "$MSG"
	else
		cmessage "$MSG\n" "$COLOR"
	fi
}

#Displays output to screen given a color
#	$1 is the message to display
#	$2 is the color to display the message as
#NOTE: will display in-line
cmessage () {
	local CODE
	local MSG="$1"
	local COLOR="$2"
		
	case "$COLOR" in
		black)	CODE='\e[0;30m';;
		red)	CODE='\e[0;31m';;
		green)	CODE='\e[0;32m';;
		yellow)	CODE='\e[0;33m';;
		blue)	CODE='\e[0;34m';;
		purple) CODE='\e[0;35m';;
		cyan)	CODE='\e[0;36m';;
		white)	CODE='\e[0;37m';;
	esac

	echo -ne "${CODE}${MSG}\e[0m"
}

#Displays output to the screen in red. If given, also writes to log file
#	$1 is the message to display
#	$2 (optional) is the log file to write to
errormessage () {
	local MSG="$1"
	local LOG="$2"

	cmessage "ERROR: $MSG" "red"

	#write to a given log file
	if [[ ! -z "$LOG" ]]
	then
		echo -e "$(date): $MSG" >&2 "$LOG"
	fi
	
	#getops:
	#write to system log
	#write to the log in LOGFILE
}

#Display message to screen, then get user input in form of yes/no/quit and return accordingly
#	$1 is the the message that will be prompted to the user
yesnoquit () {
	local MSG="$1"

	while true
	do
		message "$MSG (yes/no/quit)"
		local INPUT
		read INPUT
	
		case "$INPUT" in
			y | Y | yes | Yes)
				return 0;;
			n | N | no | No)
				return 1;;
			q | Q | quit | Quit)
				cleanup;;
			*)	message "Unkown input, please try again";;
		esac
	done
}

#write to system log
#	$1 is the message to log
log () {
	local SCRIPT="${0##*/}"
	local MSG="$1"

	logger "${SCRIPT}: $MSG"
}

#Display to screen if VERBOSE=ON
#	$1 is the message to be display
#	$2 (option) alternate color do diplay in (default cyan)
verbout () {
	local MSG="$1"
	local COLOR="$2"

	if [[ "$VERBOSE" = "ON" ]]
	then
		if [[ -z "$COLOR" ]]
		then
			message "$MSG" "cyan"
		else
			message "$MSG" "$COLOR"
		fi
	fi
}

#Display to the screen if DEBUG=ON
#	$1 is the message to be display
#	$2 (option) alternate color do diplay in (default yellow)
debugout () {
	local MSG="$1"
	local COLOR="$2"

	if [[ "$DEBUG" = "ON" ]]
	then
		if [[ -z "$COLOR" ]]
		then
			message "$MSG" "yellow"
		else
			message "$MSG" "$COLOR"
		fi
	fi
}

#Get network info of specific device
getnetinfo () {
	;
	#Use getops to return specific info
}

#Get the ip address of a specific interface
#	$1 is the interface to check
getipaddr () {
	local DEVICE="$1"
	#one liner to pull the IP off of the given device interface
	ifconfig "$DEVICE" | egrep -o "(([01]?[[:digit:]]?[[:digit:]]|2[0-4][[:digit:]]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])" | head -n 1
}

#Replaces all instances using sed
#	$1 is what should be replaced
#	$2 is what to replace with
#	$3 is the file to operate on
sedreplace () {
	local OLD="$1"
	local NEW="$2"
	local FILE="$3"
	sed -i "s/$OLD/$NEW/g" "$FILE"
}

#Check for valid IPv4 address
#	$1 is the ip to check
verifyipv4 () {
	local IP="$1"
	if [[ "$IP" =~ "^(([01]?[[:digit:]]?[[:digit:]]|2[0-4][[:digit:]]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$" ]]
	then
		return 0
	else
		return 1
	fi
}

#Create directory if it doesn't already exist
#	$1 is the directory to create
makedir () {
	local DIR="$1"
	if [[ ! -d "$DIR" ]]
	then
		mkdir "$DIR"
	else
#		verbout "$DIR already exists"
		debugout "$DIR already exists"
	fi


	#make "recursive"?
}

#Returns the timestamp of a file (default output is month/day/year)
#	$1 is the file to check
#	$2 (optional) is the specific option to return (day, month, or year)
gettimestamp () {
	local FILE="$1"
	local OPT="$2"
	local DATE="$(date +%D -r $FILE)"

	if [[ -z "$OPT" ]]
	then
		echo $DATE
	else
		#Get day/month/year
			local MONTH=${DATE%%/*}
			local REM=${DATE#*/}
			local DAY=${REM%%/*}
			local YEAR=${REM#*/}

		case "$OPT" in
			day)    echo $DAY;;
			month)  echo $MONTH;;
			year)   echo $YEAR;;
		esac
	fi

	#Add format custimization
}













