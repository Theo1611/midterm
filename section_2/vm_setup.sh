#!/bin/bash

TARGET_HOST="midterm"
INSTALL_SCRIPT_LOC="/home/midterm/setup/install_script.sh"

echo -e "\nStarting setup script...\n"

#copy setup folder onto machine                  
scp -r ./setup $TARGET_HOST:~  

#execute install script
echo "chmod 755 $INSTALL_SCRIPT_LOC && $INSTALL_SCRIPT_LOC" | ssh $TARGET_HOST

echo -e "\nDone."
