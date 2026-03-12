#!/bin/bash

############################################
#### A bunch of useful functions to use ####
####         in bash scripts            ####
############################################

FUNCTIONECHO=true

FunctionEchoOn()
{
    FUNCTIONECHO=true
#    FunctionEcho "FunctionEcho enabled."
}

FunctionEchoOff()
{
    FUNCTIONECHO=false
#    echo "FunctionEcho disabled (silent mode)."
}

FunctionEcho()
{
    if [ "$FUNCTIONECHO" == true ];
    then
        echo $1
    fi
}

PressAnyKeyToContinue()
{
    read -n 1 -s -r -p "Press any key to continue"
    echo ""
}

PressEnterToContinue()
{
    echo "Press enter key to proceed..."
    read blabla
}

YesOrNoToContinue()
{
    while true;
    do
        read -p "Do you want to continue? (yes/no): " yn
	case $yn in
	    [Yy][Ee][Ss]) echo "Continuing..."; break;;
	    [Nn][Oo]) echo "Exiting..."; exit;;
	    * ) echo "Please answer yes or no.";;
	esac
    done
}

Y_OrN_ToContinueKeypress()
{
    while true;
    do
        read -n 1 -r -p "Continue? [y/n]: " yn
        case $yn in
            [Yy]* ) echo; break;;
            [Nn]* ) echo; exit;;
            * ) echo -e "\nPlease answer yes or no.";;
        esac
    done
}

DisplayMessageInFrame() # "message to display" frameLength emptyLinesBefore displayTime(time/-)
{
	message=$1
	messagelen=${#message}
	frameLength=$2

	for (( i = 0; i < $3; i++ ))
	do
		echo ""
	done

	if [[ $messagelen -gt $frameLength ]];
	then
		frameLength=$messagelen+6
	fi

	frameString=""
	for (( i = 0; i < $frameLength; i++ ))
	do
		frameString+="#"
	done

	messageString=""
	beginFillChar=$((($frameLength - $messagelen - 2)/2))
	endFillChar=$(($frameLength - $messagelen - $beginFillChar - 2))
	for (( i = 0; i < $beginFillChar; i++ ))
	do
		messageString+="#"
	done
	messageString+=" $message "
	for (( i = 0; i < $endFillChar; i++ ))
	do
		messageString+="#"
	done
	echo $frameString
	echo $messageString
	if [[ "$4" == "time" ]];
	then
		GetSystemTime
		messageTime=$mtimeymdThms
		messageTimeLength=${#messageTime}

		if [[ $messageTimeLength -gt $frameLength ]];
		then
			frameLength=$messageTimeLength+6
            frameString=""
            for (( i = 0; i < $frameLength; i++ ))
            do
                frameString+="#"
            done
		fi
		
		messageTimeString=""
		beginFillChar=$((($frameLength - $messageTimeLength - 2)/2))
		endFillChar=$(($frameLength - $messageTimeLength - $beginFillChar - 2))
		for (( i = 0; i < $beginFillChar; i++ ))
		do
			messageTimeString+="#"
		done
		messageTimeString+=" $messageTime "
		for (( i = 0; i < $endFillChar; i++ ))
		do
			messageTimeString+="#"
		done
		echo $messageTimeString
	fi
	echo $frameString
}


GetOwnIP()
{
    #OWNIP=`ifconfig ${NET_IF} | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
    OWNIP=`ip a ${NET_IF} | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
    FunctionEcho "Own IP: $OWNIP"   
}

GetHostname()
{
    HOSTNAME=$(cat /etc/hostname)
    FunctionEcho "Hostname: $HOSTNAME"
}
################################################################################################

GetProgramName()
{
    PROGRAM_NAME=`basename "$0"`
    #PROGRAM_NAME=$(basename $(readlink -f $0))
    FunctionEcho "ProgramName: $PROGRAM_NAME"
}

GetProgramPath()
{
    # Path where script runs
    PROGRAM_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    #PROGRAM_PATH="$(dirname "$(dirname "$(readlink -fm "$0")")")"
    FunctionEcho "ProgramPath: $PROGRAM_PATH"
}

GetScriptLaunchPath()
{
    SCRIPTLAUNCHPATH=$PWD
    FunctionEcho "Script launch path: $SCRIPTLAUNCHPATH"
}

GetNumberOfCPUs()
{
	NCPU=$(grep -c ^processor /proc/cpuinfo)
    # 64 bit systems need more memory for compilation
    if [ $(getconf LONG_BIT) -eq 64 ] && [ $(grep MemTotal < /proc/meminfo | cut -f 2 -d ':' | sed s/kB//) -lt 5000000 ]
    then
        echo "Low memory limiting to JOBS=2"
        NCPU=2
    fi

#	echo "Number of CPUs: $NCPU"
	FunctionEcho "Number of CPUs: $NCPU"

}

NoRunAsRoot()
{
    if [ "$(whoami)" == "root" ];
    then
        echo "This script can not be run run as root. Exiting..."
        exit
    fi
    FunctionEcho "Running script as ordinary user..."
}

RunAsRoot()
{
    if [ "$(whoami)" != "root" ];
    then
        echo "This script has to be run as root. Exiting..."
        exit
    fi
    FunctionEcho "Running script as root..."
}

InstallList()
{
    # Install packages listed in a file."
    # Usage: InstallList filename
    # Usage: InstallList filename [section] - if the list is under a section in the filename
	FILE=$1
	SECTION=$2
	in_section=false
	COMMANDTORUN="apt-get install -y"

	if [ ! -f $FILE ];
	then
		echo "File $FILE not found!"
		exit 1
	fi

	while IFS= read -r line;
	do
        # Check if the second parameter exists
        if [ -n "$2" ];
        then
            # Check if we hit the start of our target section
            if [[ "$line" == "$SECTION" ]];
            then
                in_section=true
                continue
            fi
            
            # Check if we hit another section header
            if [[ "$line" =~ ^\[.*\] ]];
            then
                in_section=false
            fi
        else
            in_section=true
        fi

		# Print lines if we are inside the section
		if [ "$in_section" == true ];
        then
			# Skip comments and empty lines
			[[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        
			# Trim potential whitespace and assign to variable
			listitem=$(echo "$line" | tr -d '[:space:]')
			COMMANDTORUN+=" $listitem"
		fi
	done < "$FILE"
	FunctionEcho "COMMAND: $COMMANDTORUN"
	FunctionEcho "Installing the packages from the list..."
	$COMMANDTORUN
}

ReadSettings()
{
	FILE=$1
	SECTION=$2
	in_section=false

	if [ ! -f $FILE ];
	then
		echo "File $FILE not found!"
		exit 1
	fi

	while IFS='=' read -r key value;
	do
		# Check if we hit the start of our target section
		if [[ "$key" == "$SECTION" ]];
		then
			in_section=true
			continue
		fi
		
		# Check if we hit another section header
		if [[ "$key" =~ ^\[.*\] ]];
		then
			in_section=false
		fi

		# Print lines if we are inside the section
		if [ "$in_section" == true ];
        then
			[[ -z "$key" ]] && continue

			# Skip comments and empty lines
			[[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
        
			# Trim potential whitespace and assign to variable
			key=$(echo "$key" | tr -d '[:space:]')
			value=$(echo "$value" | tr -d '[:space:]')
        
			# Assign the value to a variable named after the key
#			declare "$key=$value" # local variables
#			declare -g "$key=$value" # global variables
			eval "$key=$value" # global variables
		fi
	done < "$FILE"
}

GetDistroName()
{
	# Extract the NAME field, remove the "NAME=" prefix, 
	# and strip away the quotes and any trailing version info.
	DISTRO_NAME=$(grep -w "NAME" /etc/os-release | sed 's/NAME=//;s/"//g' | awk '{print $1}')
	FunctionEcho "Distro name: $DISTRO_NAME"
}

GetDistroVersion()
{
	# 1. The modern standard (works on most distributions)
	if [ -f /etc/os-release ];
	then
		. /etc/os-release
		DISTRO_VERSION=$VERSION_ID
	# 2. Fallback to lsb_release command (common on Ubuntu/Debian)
	elif type lsb_release >/dev/null 2>&1;
	then
		DISTRO_VERSION=$(lsb_release -sr)
	# 3. Final fallback to uname (provides kernel version)
	else
		DISTRO_VERSION=$(uname -r)
	fi
	FunctionEcho "Distro version: $DISTRO_VERSION"
}

CompareVersions()
{
	# Compare 2 version strings
	# Parameter 1 is the first version string
	# Parameter 2 is the second version string
	# Parameter 3 is the separator
	# Parameter 4 is the prefix
	# Ex: CompareVersions v1_2_3 v1_2_4 _ v
	# Output: 0 if equal; 2 if Parameter 1 > Parameter 2; 1 if Parameter 1 < Parameter 2
	# Catch the output of the function using: comparison=$(CompareVersions v1_2_3 v1_2_4 _ v)
	SEPARATOR=$3
	PREFIX=$4
	if [ -z $PREFIX ];
	then
		PREFIX=v
	fi
	if [ -z $SEPARATOR ];
	then
		SEPARATOR=.
	fi	
	param1=$(printf "%03d%03d%03d%03d" $(echo "$1" | tr $SEPARATOR ' ' | tr $PREFIX ' '))
	param2=$(printf "%03d%03d%03d%03d" $(echo "$2" | tr $SEPARATOR ' ' | tr $PREFIX ' '))
	if [[ $param1 == $param2 ]];
	then
		echo 0
	fi
	if [[ $param1 > $param2 ]];
	then
		echo 2
	fi
	if [[ $param1 < $param2 ]];
	then
		echo 1
	fi
}

GetStandardVersionFormat()
{
	# Transforms a custom version format (v1_2_3)
	# into a standard format (1.2.3)
	# Parameter 1 is custom version string
	# Parameter 2 is the separator
	# Parameter 3 is the prefix
	# Ex: GetStandardVersionFormat v1_2_3 _ v
	# Catch the output of the function using: standardVersion=$(GetStandardVersionFormat v1_2_3 _ v)
	SEPARATOR=$2
	PREFIX=$3
	if [ -z $PREFIX ];
	then
		PREFIX=v
	fi
	if [ -z $SEPARATOR ];
	then
		SEPARATOR=.
	fi	
	param=$(echo "$1" | tr $SEPARATOR '.' | tr $PREFIX ' ')
	echo "$param"
}

GetCustomVersionFormat()
{
	# Transforms a standard version format (1.2.3)
	# into a custom format (v1_2_3)
	# Parameter 1 is custom version string
	# Parameter 2 is the separator
	# Parameter 3 is the prefix
	# Ex: GetCustomVersionFormat 1.2.3 _ v
	# Catch the output of the function using: customVersion=$(GetCustomVersionFormat 1.2.3 _ v)
	SEPARATOR=$2
	PREFIX=$3
	if [ -z $PREFIX ];
	then
		PREFIX=v
	fi
	if [ -z $SEPARATOR ];
	then
		SEPARATOR=.
	fi	
	param=$(echo "$1" | tr '.' $SEPARATOR)
	param=$PREFIX$param
	echo "$param"
}

GetSystemTime()
{
    mytime=$(date +"%Y-%m-%d_%H.%M.%S")
    secondscount=$(date +"%s") # seconds since 01.01.1970
    msecond=$(date +"%S")
    mminute=$(date +"%M")
    mhour=$(date +"%H")
    mday=$(date +"%d")
    mday_yesterday=$(date +"%e" -d "yesterday")
    mmonth=$(date +"%m")
    mmonthname=$(date +"%b")
    mmonthnamefull=$(date +"%B")
    mmonthname_yesterday=$(date +"%b" -d "yesterday")
    mmonthnamefull_yesterday=$(date +"%B" -d "yesterday")
    myear=$(date +"%Y")
    mtimehms=$mhour:$mminute:$msecond
    mdateymd=$myear-$mmonth-$mday
    mtimeymdhms="$mdateymd@$mtimehms"
    mtimeymd_hms=$mdateymd"_"$mtimehms
    mtimeymdThms=$mdateymd"T"$mtimehms
}

PrintSystemTime()
{
    GetSystemTime
    echo
    echo mytime=$mytime
    echo secondscount=$secondscount
    echo msecond=$msecond
    echo mminute=$mminute
    echo mhour=$mhour
    echo mday=$mday
    echo mday_yesterday=$
    echo mmonth=$mmonth
    echo mmonthname=$mmonthname
    echo mmonthnamefull=$mmonthnamefull
    echo mmonthname_yesterday=$mmonthname_yesterday
    echo mmonthnamefull_yesterday=$mmonthnamefull_yesterday
    echo myear=$myear
    echo mtimehms=$mtimehms
    echo mdateymd=$mdateymd
    echo mtimeymdhms=$mtimeymdhms
    echo mtimeymd_hms=$mtimeymd_hms
    echo mtimeymdThms=$mtimeymdThms
    echo
}

DisplayElapsedTime() # initialTime (seconds since 01.01.1970)
{
    GetSystemTime
    local seconds=$(($secondscount-$1))
    local minutes=$(($seconds/60))
    local rSeconds=$(($seconds-$minutes*60))
    local hours=$(($minutes/60))
    local rMinutes=$(($minutes-$hours*60))
    echo "Time elapsed: "$hours" hours, "$rMinutes" minutes, "$rSeconds" seconds."
}

MailSend_Mutt() # "username"; "recipient"; "subject"; "mailbody"; "attachmenntPath"
{
# Use quotes for the parameter if it has spaces.
# If running script as root, first parameter is the username of the sending user.
# If script is run by user, username does not matter but some string has to be passed as first parameter.
# mutt must be installed (apt install mutt) and configured for the sending user

    if [[ -n $param5 ]]
    then
        if [ "$(whoami)" == "root" ];
        then
            runuser -l  $param1 -c "echo $4 | mutt '$2' -s '$3' -a '$5'"
        else
            echo $param4 | mutt "$2" -s "$3" -a "$5"
        fi
    else
        if [ "$(whoami)" == "root" ];
        then
            runuser -l  $param1 -c "echo $4 | mutt '$2' -s '$3'"
        else
            echo $param4 | mutt "$2" -s "$3"
        fi
    fi
}

MailSend_LocalString() # "recipient"; "subject"; "mailbody"; "attachmenntPath"
{
    # sending mail on the local host
    # mailbody is a string
    if [[ -n $param4 ]]
    then
        echo "$3" | /usr/bin/mail "$1" -s "$2" -A "$4"
    else
        echo "$3" | /usr/bin/mail "$1" -s "$2"
    fi
}

MailSend_LocalFile() # "recipient"; "subject"; "mailbodyFilePath"; "attachmenntPath"
{
    # sending mail on the local host
    # mailbody is a file
    if [[ -n $param4 ]]
    then
        /usr/bin/mail "$1" -s "$2" -A "$4" < "$3"
    else
        /usr/bin/mail "$1" -s "$2" < "$3"
    fi
}
