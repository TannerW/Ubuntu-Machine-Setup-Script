#!/usr/bin/env bash

# initalize array of all packages
# UH OH... global variable?? Don't worry, it stays constant.
readonly FULLPACKAGELIST=(openssh-server tightvncserver xrdp htop tree git-core cmake build-essential nodejs npm)
readonly REMOTEPACKAGELIST=(openssh-server tightvncserver xrdp)
readonly QOLPACKAGELIST=(htop tree)
readonly CODEPACKAGELIST=(git-core cmake build-essential)
readonly WEBPACKAGELIST=(nodejs npm)

# Helper function used to send messages to STDERR
err() {
  printf "\n\n[$(date +'%Y-%m-%dT%H:%M:%S%z')]:$@\n\n" >&2
}

showHelp() {
	man -P cat "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"/manpage_files/setupNewUbuntu.1
}

listOptions() {
	man -P cat "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"/manpage_files/setupNewUbuntuOptionsOnly.1
}

askAboutDefault() {
	while true; do
	    read -p $'!!! No installation type option detected !!!\nDoes this mean you wish to install the full suite of applications targeted by this setup script? (Not sure? Then please response No to see a list of options)\n[y/n]:' yn
	    case $yn in
	        [Yy]* ) break;;
	        [Nn]* ) err "\nUSAGE: sudo $1 [BASIC OPTIONS] [INSTALL TYPE OPTIONS] [INSTALL MODE OPTIONS]"; listOptions; printf "\nNeed more help? type \`sudo $1 --help\`\n"; exit 1;;
	        * ) printf "Please answer yes or no.";;
	    esac
	done
}

remoteSuiteProcess() {

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

}

QoLSuiteProcess() {

	# install htop, its a better `top` experience
	sudo apt-get --yes install htop

	# install tree, a visual and recursive approach to an `ls`
	sudo apt-get --yes install tree

}

codeSuiteProcess() {
	
	# get git
	sudo apt-get --yes install git-core

	# install cmake 
	sudo apt-get --yes install cmake

	# install build-essentials to make sure you have your C/C++ essentials
	sudo apt-get --yes install build-essential

}

webDevSuiteProcess() {
	# install node and node's package manager
	sudo apt-get --yes install nodejs
	sudo apt-get --yes install npm
}

main() {
	#set -o errexit
	set -o pipefail # 
	set -o nounset # Exit if an undeclared variable is referenced
	#set -o xtrace # Trace executed commands... you can disable this unless you are debugging

	# Set magic variables for current file & dir
	__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
	__base="$(basename ${__file} .sh)"
	__root="$(cd "$(dirname "${__dir}")" && pwd)"

	echo "$__dir"
	echo "$__file"
	echo "$__base"
	echo "$__root"


	installTypeSet=false

	fullSuite=false
	remoteSuite=false
	QoLSuite=false
	codeSuite=false
	webDevSuite=false

	removeFullSuite=false
	removeRemoteSuite=false
	removeQoLSuite=false
	removeCodeSuite=false
	removeWebDevSuite=false

	fastMode=false
	skipAptUpgrade=false
	skipAptUpdate=false

	# Check for valid input arguments
	if [ "$#" -lt "1" ]
	then
		askAboutDefault "$0"

		printf "\n\n Great! I'll take care of installing the full-suite of tools for you. Sit back and relax, this may take a few mintues...\n\n"
	else
		while :; do
		    case $1 in
		        -h|-\?|--help)
		            showHelp    # Display a usage synopsis.
		            exit
		            ;;
		        --full-suite)
					fullSuite=true
					installTypeSet=true
					;;
				--uninstall-full-suite)
					removeFullSuite=true
					installTypeSet=true
					;;
				--remote-suite)
					remoteSuite=true
					installTypeSet=true
					;;
				--uninstall-remote-suite)
					removeRemoteSuite=true
					installTypeSet=true
					;;
				--QoL-suite)
					QoLSuite=true
					installTypeSet=true
					;;
				--uninstall-QoL-suite)
					removeQoLSuite=true
					installTypeSet=true
					;;
				--code-suite)
					codeSuite=true
					installTypeSet=true
					;;
				--uninstall-code-suite)
					removeCodeSuite=true
					installTypeSet=true
					;;
				--webDev-suite)
					webDevSuite=true
					installTypeSet=true
					;;
				--uninstall-webDev-suite)
					removeWebDevSuite=true
					installTypeSet=true
					;;
				--fast-mode)
					fastMode=true
					;;
				--no-apt-update)
					skipAptUpdate=true
					;;
				--no-apt-upgrade)
					skipAptUpgrade=true
					;;
		        # -v|--verbose)
		        #     verbose=$((verbose + 1))  # Each -v adds 1 to verbosity.
		        #     ;;
		        # --)              # End of all options.
		        #     shift
		        #     break
		        #     ;;
		        -?*)
		            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
		            ;;
		        *)               # Default case: No more options, so break out of the loop.
		            break
		    esac

		    shift
		done

		#if an installation type is not defined in the options, then check with the user to make sure that the full suite is the option they want.
		if [ "$installTypeSet" = false ]
		then
			askAboutDefault "$0"
		fi
	fi

	#if fast-mode is on, initialize the setup of apt-fast
	if [ "$fastMode" = true ]
	then
		sudo add-apt-repository -y ppa:apt-fast/stable
	fi


	#update the package repo
	if [ "$skipAptUpdate" = false ] || [ "$fastMode" = true ]
	then
		sudo apt-get --yes update
	fi
	#upgrade existing packages to get everything up to date
	if [ "$skipAptUpgrade" = false ]
	then
		sudo apt-get --yes upgrade
	fi

	#finish up the installation needed for fast mode
	if [ "$fastMode" = true ]
	then
		sudo apt-get -y install apt-fast

		printf "\n\n\n====================================================================\nFAST MODE ENABLED... INITIALIZING PARALLEL INSTALLATION PROCESS...\n====================================================================\n\n\n"
	fi

	# ======== REMOTE USER TOOLS ========
	remoteSuiteProcess "$" "$" "$"



	# ======== QUALITY OF LIFE PACKAGES ========
	QoLSuiteProcess "$" "$" "$"



	# ======== BASIC CODE (OOP and Scripting) DEVELOPMENT PACKAGES ========
	codeSuiteProcess "$" "$" "$"



	# ======== BASIC WEB DEVELOPMENT PACKAGES ========
	webDevSuiteProcess "$" "$" "$"




	# ======== CLEAN UP ========
	#keep up the utilities from fast mode
	if [ "$fastMode" = true ]
	then
		sudo apt-get -y remove apt-fast
		sudo add-apt-repository -r -y ppa:apt-fast/stable
		sudo apt-get --yes update
	fi

	# clean up auto install packages
	sudo apt --yes autoremove



	printf "\n\n ... And there you go! It looks like everything went well during the installation process and your Ubuntu environment is ready for use!"
}

main