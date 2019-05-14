sudo apt-get update
sudo apt-get upgrade

# install and setup ssh
sudo apt-get -y install openssh-server
sudo systemctl start ssh #just to make sure
sudo systemctl enable ssh #just to make sure

# install vncserver and xrdp so i can remote decktop into gnome :P 
# cause ya know... sometimes pure CLI is exhausting for interface
# oriented stuff
sudo apt-get -y install tightvncserver
sudo apt-get -y install xrdp
sudo service xrdp restart # just in case... cant hurt

# get git
auso apt-get -y install git-core

# htop... cause htop is sick...
sudo apt-get -y install htop

# tree... can be useful command at times
sudo apt-get -y install tree

# rsub... because you haven't lived until you've used sublime tunneling
sudo wget -O /usr/local/bin/rmate https://raw.githubusercontent.com/aurora/rmate/master/rmate
sudo chmod a+x /usr/local/bin/rmate

# cmake... to make life easier
sudo apt-get -y install cmake