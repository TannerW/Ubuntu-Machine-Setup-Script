#!/usr/bin/env bash

# initalize array of all packages
# UH OH... global variable?? Don't worry, it stays constant.
readonly FULLPACKAGELIST=(openssh-server tightvncserver xrdp htop tree git-core cmake build-essential nodejs npm)
readonly REMOTEPACKAGELIST=(openssh-server tightvncserver xrdp)
readonly QOLPACKAGELIST=(htop tree)
readonly CODEPACKAGELIST=(git-core cmake build-essential)
readonly WEBPACKAGELIST=(nodejs npm)

# Set magic variables for current file & dir
readonly __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly __file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
readonly __base="$(basename ${__file} .sh)"
readonly __root="$(cd "$(dirname "${__dir}")" && pwd)"

# Helper function used to send messages to STDERR
err() {
  printf "\n\n[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@\n\n" >&2
}

listOptions() {
	man -P cat "$(basename ${__file} .sh)"/setupNewUbuntu.1
}

main() {
	# Check for valid input arguments
	if [ "$#" -lt "1" ]
	then
		while true; do
		    read -p $'!!! No installation type option detected !!!\nDoes this mean you wish to install the full suite of applications targeted by this setup script? (Not sure? Then please response No to see a list of options)\n[y/n]:' yn
		    case $yn in
		        [Yy]* ) break;;
		        [Nn]* ) err "USAGE: sudo $0 [INSTALL TYPE OPTIONS] [INSTALL MODE OPTIONS]"; listOptions; exit 1;;
		        * ) printf "Please answer yes or no.";;
		    esac
		done

		printf "\n\n Great! I'll take care of installing the full-suite of tools for you. Sit back and relax, this may take a few mintues...\n\n"
	#else
		# while getopts ":ht" opt; do
		#   case ${opt} in
		#     --full-suite ) # process option a
		#       ;;
		#     t ) # process option t
		#       ;;
		#     \? ) echo "Usage: sudo cmd [--full-suite | --"
		#       ;;
		#   esac
		# done
	fi

	#set -o errexit
	set -o pipefail # 
	set -o nounset # Exit if an undeclared variable is referenced
	set -o xtrace # Trace executed commands... you can disable this unless you are debugging

	# Set magic variables for current file & dir
	__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
	__base="$(basename ${__file} .sh)"
	__root="$(cd "$(dirname "${__dir}")" && pwd)"



	#update the package repo
	sudo apt-get --yes update
	#upgrade existing packages to get everything up to date
	sudo apt-get --yes upgrade



	# ======== REMOTE USER TOOLS ========

	# install and setup ssh
	sudo apt-get --yes install openssh-server
	sudo systemctl start ssh # Probably default, but just to make sure
	sudo systemctl enable ssh # Probably default, but just to make sure

	# install vncserver and xrdp so i can remote desktop into gnome
	sudo apt-get --yes install tightvncserver
	sudo apt-get --yes install xrdp
	sudo service xrdp restart # sometimes xrdp is oddly behaved after install.. restart just in case.

	# install rmate to enable the use of sublime port tunneling through ssh
	sudo wget --output-document=/usr/local/bin/rsub https://raw.github.com/aurora/rmate/master/rmate
	sudo chmod a+x /usr/local/bin/rsub



	# ======== QUALITY OF LIFE PACKAGES ========

	# install htop, its a better `top` experience
	sudo apt-get --yes install htop

	# install tree, a visual and recursive approach to an `ls`
	sudo apt-get --yes install tree



	# ======== BASIC CODE (OOP and Scripting) DEVELOPMENT PACKAGES ========

	# get git
	sudo apt-get --yes install git-core

	# install cmake 
	sudo apt-get --yes install cmake

	# install build-essentials to make sure you have your C/C++ essentials
	sudo apt-get --yes install build-essential



	# ======== BASIC WEB DEVELOPMENT PACKAGES ========

	# install node and node's package manager
	sudo apt-get --yes install nodejs
	sudo apt-get --yes install npm



	# ======== CLEAN UP ========

	# clean up auto install packages
	sudo apt --yes autoremove



	printf "\n\n ... And there you go! It looks like everything went well during the installation process and your Ubuntu environment is ready for use!"
}

main