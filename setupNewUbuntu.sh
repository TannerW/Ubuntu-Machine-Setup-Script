#!/usr/bin/env bash

# Helper function used to send messages to STDERR
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

# Check for valid input arguments
if [ "$#" -lt "1" ]
then
	while true; do
	    read -p "!!! No install options detected !!! \n Does this mean you wish to install the full suite of applications targeted by this setup script? (Not sure? Please response No to see a list of options) [y/n]:" yn
	    case $yn in
	        [Yy]* ) break;;
	        [Nn]* ) err "USAGE: $0 [--full-suite | ] "; exit 1;;
	        * ) echo "Please answer yes or no.";;
	    esac
	done

	echo "\n\n Great! I'll take care of installing the full-suite of tools for you. Sit back and relax, this may take a few mintues...\n\n"
else
	# while getopts ":ht" opt; do
	#   case ${opt} in
	#     --full-suite ) # process option a
	#       ;;
	#     t ) # process option t
	#       ;;
	#     \? ) echo "Usage: cmd [--full-suite | --"
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



sudo apt-get --yes update
sudo apt-get --yes upgrade

# install and setup ssh
sudo apt-get --yes install openssh-server
sudo systemctl start ssh # Probably default, but just to make sure
sudo systemctl enable ssh # Probably default, but just to make sure

# install vncserver and xrdp so i can remote desktop into gnome
sudo apt-get --yes install tightvncserver
sudo apt-get --yes install xrdp
sudo service xrdp restart # sometimes xrdp is oddly behaved after install.. restart just in case.

# get git
sudo apt-get --yes install git-core

# install htop, its a better `top` experience
sudo apt-get --yes install htop

# install tree, a visual and recursive approach to an `ls`
sudo apt-get --yes install tree

# install rmate to enable the use of sublime port tunneling through ssh
sudo wget --output-document=/usr/local/bin/rmate https://raw.githubusercontent.com/aurora/rmate/master/rmate
sudo chmod a+x /usr/local/bin/rmate

# install cmake 
sudo apt-get --yes install cmake

# install build-essentials to make sure you hjave your C/C++ essentials
sudo apt-get --yes install build-essential

# install node and node's package manager
sudo apt-get --yes install nodejs npm

echo "\n\n ... And there you go! It looks like everything went well during the installation process and your Ubuntu environment is ready for use!"