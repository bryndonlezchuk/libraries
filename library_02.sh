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

	if [[ -z $1 ]]
	then
		exit 0
	elif [[ $1 =~ [0-9]* ]]
	then
		exit "$1"
	else	
		exit 1
	fi
}

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













