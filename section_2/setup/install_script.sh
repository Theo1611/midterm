#!/bin/bash

GIT_REPO="https://github.com/wayou/HiChat.git"
SETUP_DIR="/home/midterm/setup"
SRV_USER="hichat"
SRV_USER_HOME="/app"
SRV_USER_PASS="disabled"

#install packages
install_packages() {
	sudo yum install -y git nodejs nginx
	}

#create service user
create_user() {
	#remove user if exists
	sudo pkill -u $SRV_USER
	sudo userdel -r $SRV_USER
	#add new user
	sudo useradd -r -m $SRV_USER -d $SRV_USER_HOME
	(sudo echo $SRV_USER_PASS; sudo echo $SRV_USER_PASS) | sudo passwd $SRV_USER
	#give proper permission so later on nginx user can read files
	sudo chmod 755 $SRV_USER_HOME
	}

#Clone project and install dependencies	
set_up_app() {
	#bypass "cannot change back to /home/admin/" permission error
	cd /tmp
	#clone project
	sudo -u $SRV_USER git clone $GIT_REPO $SRV_USER_HOME/app
	#install dependencies
	sudo -u $SRV_USER npm install --prefix $SRV_USER_HOME/app
	}

#configure services
configure_services() {
	#configure nginx
	sudo cp $SETUP_DIR/nginx.conf /etc/nginx
	#create service
	sudo cp $SETUP_DIR/hichat.service /etc/systemd/system/
	sudo systemctl daemon-reload
	}

#enable & start services
start_services() {
	#start services in sequence
	sudo systemctl enable hichat && sudo systemctl restart hichat
	sudo systemctl enable nginx && sudo systemctl restart nginx
}

echo -e "\nStarting install script... \n"

install_packages
create_user
set_up_app
configure_services
start_services

echo -e "\nInstall script finished.\n"
