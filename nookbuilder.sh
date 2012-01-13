#!/bin/bash

# This script will help you build a kernel for the nook based on CM7.

# Created by: Ivan Maldonado

VERSION="1.0"

if [[ $1 == "--version" || $1 == "-v" ]]
then
echo "NookBuilder" $VERSION
echo "Copyright (C) 2010 Free Software Foundation, Inc."
echo "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>."
echo "This is free software: you are free to change and redistribute it."
echo "There is NO WARRANTY, to the extent permitted by law."
echo "Written by Ivan Maldonado."
exit
fi

if [[ $1 == "--help" || $1 == "-h" ]]
then
echo "Usage: ./nookbuilder [OPTION]"
echo "This script will download everything that you need to compile a NookColor"
echo "kernel based on CM7's kernel. In the future it may do more..."
echo ""
echo "Options:"
echo "-h, --help Display this help and exit."
echo "-v, --version Output version information and exit."
exit
fi

# Verify Java JDK is installed.
# If not found, install.

REQUIRED_VERSION=sun-java6-jdk
VERSION=`dpkg --get-selections | awk '/\Winstall/{print $1}' | grep sun-java6-jdk`

if [ $(($VERSION)) -eq $(($REQUIRED_VERSION)) ]
then
echo "Required version of Java detected."
else
sudo add-apt-repository ppa:ferramroberto/java
sudo apt-get update
sudo apt-get -y install sun-java6-jdk

# Set Java version to use by default.
sudo update-java-alternatives -s java-6-sun
fi

# Install required software.
sudo apt-get install git-core gnupg sun-java6-jdk flex bison gperf libsdl-dev libesd0-dev libwxgtk2.6-dev build-essential zip curl libncurses5-dev zlib1g-dev

clear

# Create needed folders holding folder if they do not exist.
if [ ! -d prebuilt ]
then
echo "Error: Cannot find toolchain."
echo "Please wait while the toolchain is downloaded..."
wget http://www.codesourcery.com/sgpp/lite/arm/portal/package6493/public/arm-none-eabi/arm-2010q1-188-arm-none-eabi-i686-pc-linux-gnu.tar.bz2
tar xvjf arm-2010q1-188-arm-none-eabi-i686-pc-linux-gnu.tar.bz2
rm arm-2010q1-188-arm-none-eabi-i686-pc-linux-gnu.tar.bz2
mv arm-2010q1 prebuilt
clear
fi


# The following are functions that I don't want to have to repeat.

#################################################
#		Start of Functions		#
#################################################

update() {
if [ ! -d sourcecode ]
then
echo "No source found. Please download source first."
zenity --warning --title "Error" --text "No source found. Please download source first."
mainmenu
else
cd sourcecode
git pull
cd ..
fi
mainmenu
}

kernel29() {
# Check for source code. If it doesn't exist, download it. If it exists, switch to the .29 branch.
if [ ! -d sourcecode ]
then
echo "No source found..."
echo "Please wait while the source is downloaded..."
git clone git://github.com/dalingrin/nook_kernel.git sourcecode
fi
echo "Please wait while we switch the source to 2.6.29..."
cd sourcecode
git checkout gingerbread-29
cd ..
mainmenu
}


kernel32() {
# Check for source code. If it doesn't exist, download it. If it exists, switch to the .29 branch.
if [ ! -d sourcecode ]
then
echo "No source found..."
echo "Please wait while the source is downloaded..."
git clone git://github.com/dalingrin/nook_kernel.git sourcecode
fi
echo "Please wait while we switch the source to 2.6.32..."
cd sourcecode
git checkout encore-32-zOMG
cd ..
mainmenu
}

buildkernel() {
cd sourcecode
export CCOMPILER=../prebuilt/bin/arm-none-eabi-

#if [ ! -d arch/arm/configs/omap3621_dalingrin_defconfig ]
#then
#cp arch/arm/configs/omap3621_evt1a_defconfig .config
#else
#cp arch/arm/configs/omap3621_dalingrin_defconfig .config
#fi
make ARCH=arm CROSS_COMPILE=$CCOMPILER -j4
cd ..
mainmenu
}

cleanbuild() {
cd sourcecode
export CCOMPILER=../prebuilt/bin/arm-none-eabi-
make ARCH=arm CROSS_COMPILE=$CCOMPILER -j4 clean
cd ..
mainmenu
}

editscript() {
gedit nookbuilder.sh
exit
}

mainmenu() {
	choice=`zenity --title "NookBuilder $VERSION by ivanmmj" --text "Welcome!" --height 250 --width 380 --list --radiolist --column "" --column " Please Select An Option" False "Download/Switch to 2.6.29 kernel" False "Download/Switch to 2.6.32 kernel" True "Update current kernel source" False "Build Kernel"  False "Clean Build" False "Edit this script" False "Exit"`
	
	case $choice in
		"Download/Switch to 2.6.29 kernel")kernel29;;
		"Download/Switch to 2.6.32 kernel")kernel32;;
		"Update current kernel source")update;;
		"Build Kernel")buildkernel;;
		"Clean Build")cleanbuild;;
		"Edit this script")editscript;;
		"Exit")exit;;
	esac
}

#################################################
#		End of Functions		#
#################################################







mainmenu

