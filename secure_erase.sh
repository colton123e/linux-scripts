#!/bin/bash

###################
# HELP            #
###################
display_help()
{
  #Display Help
  echo "Custom Secure Erase Help"
  echo
  echo "Syntax: $0 [-options]"
  echo
  echo "-d <drive>	Use this option to wipe only HDDs (uses the shred"
  echo "		(and then badblocks commands to securely wipe the HDD)."
  echo "-s <drive>	Use this option to wipe only SSDs (uses the hdparm"
  echo "		command to properlywipe the SSD)."
  echo "-l	List attached disks with grepping for only non-loop devices"
  echo "-e	Run the fdisk -l command to list attached disks in detail"
  echo
  exit 1
}

## Display help if no options are given, or help option is given
if [[ "$1" == "-h" || "$1" == "--help" || $# -eq 0 ]] ; then
	display_help
	exit 0
fi

## Process the options
while getopts ":d:s:ale" option;
do
	case $option in
	    d) drivename=${OPTARG};;
	    s) ssdname=${OPTARG};;
	    l) fdisk -l | grep '/dev/sd*'
	       exit 1
	       ;;
	    e) fdisk -l
	       exit 1
	       ;;
	    :) echo "$0: -$OPTARG needs a value" >&2;
	       exit 2
	       ;;
	    \?) echo "$0: unknown option -$OPTARG" >&2;
	        exit 3
	        ;;
	esac
done

## Erase the HDD
if [ "$1" == "-d" ] ; then
   while true; do
	echo "This should only be done on an HDD (use -s for SSDs)."
	echo "Confirm you want to erase drive '${drivename}', this cannot be undone"
	read -p "and will permantly erase the contents of this drive! (Y|N) " yn
	case $yn in
		[Yy]* ) echo "Yes selected...begin erasing."; break;;
		[Nn]* ) echo "No selected...exiting."; exit;;
		* ) echo "Please answer yes or no.";;
	esac
   done
   shred -vfz -n 6 ${drivename}
   echo "Erase complete!"
	exit 1

## Erase the SSD	
elif [ "$1" == "-s" ] ; then
   while true; do
	echo "This should only be done on an SSD (use -d for HDDs)."
	echo "Confirm you want to erase SSD drive '${ssdname}', this cannot be undone"
	read -p "and will permantly erase the contents of this drive! (Y|N) " yn
	case $yn in
		[Yy]* ) echo "Yes selected...begin erasing."; break;;
		[Nn]* ) echo "No selected...exiting."; exit;;
		* ) echo "Please answer yes or no.";;
	esac
   done
   state=$( hdparm -I ${ssdname} | awk '/locked/ {print $1}' )
   erasesupport=$( hdparm -I ${ssdname} | awk '/supported:/ {print $2,$3}' )
   echo "state: ${state}"
   echo "supported: ${erasesupport}"
   
   if [[ "$state" == "not"  &&  "$erasesupport" == "enhanced erase" ]] ; then
   #Continue with erase
   echo "Test"
   fi
	exit 1
fi



