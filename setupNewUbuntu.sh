sudo apt-get update
sudo apt-get upgrade

# install vncserver and xrdp so i can remote decktop into gnome :P 
# cause ya know... sometimes pure CLI is exhausting for interface
# oriented stuff
sudo apt-get -y install tightvncserver
sudo apt-get -y install xrdp
sudo service xrdp restart # just in case... cant hurt

# htop... cause htop is sick...
sudo apt-get -y install htop

# tree... can be useful command at times
sudo apt-get -y install tree

# rsub... because you haven't lived until you've used sublime tunneling
sudo wget -O /usr/local/bin/rsub https://raw.github.com/aurora/rmate/master/rmate
sudo chmod +x /usr/local/bin/rsub

# vim... duh
sudo apt-get -y install vim

# cmake... to make life easier
sudo apt-get -y install cmake