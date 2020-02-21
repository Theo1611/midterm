#!/bin/bash
vbmg () { /mnt/c/Program\ Files/Oracle/VirtualBox/VBoxManage.exe "$@"; }
NET_NAME="NATMIDTERM"
IP_RANGE="192.168.10.0/24"
VM_NAME="MIDTERM4640"
NEW_VM_NAME="A01040617"
VM_SSH="midterm"
VM_IP="192.168.10.10"
SSH_PORT="12922"
WEB_PORT="12980"

# This function will clean the NAT network and restore machine name
clean_all () {
	vbmg natnetwork remove --netname "$NET_NAME"
	vbmg modifyvm "$NEW_VM_NAME" --name "$VM_NAME"
	}

# Creates NAT network	
create_network () {
	vbmg natnetwork add --netname "$NET_NAME" --network "$IP_RANGE" --dhcp off --ipv6 off --port-forward-4 "rule1:tcp:[127.0.0.1]:$SSH_PORT:["$VM_IP"]:22" --port-forward-4 "rule2:tcp:[127.0.0.1]:$WEB_PORT:["$VM_IP"]:80" --enable
}

# Connect vm to NAT network and change vm name
configure_vm(){
	vbmg modifyvm "$VM_NAME" --name "$NEW_VM_NAME"
	vbmg modifyvm "$NEW_VM_NAME" --nic1 natnetwork --nat-network1 "$NET_NAME"
}

# Starts the vm and waits till it's up
start_vm () {
	vbmg startvm "$NEW_VM_NAME"
	test_vm_connection
}

# Detects when vm wakes up
test_vm_connection() { 
	while /bin/true; do
		ssh $VM_SSH -o ConnectTimeout=4 -o StrictHostKeyChecking=no \
			-o UserKnownHostsFile=/dev/null \
			-q exit
		if [ $? -ne 0 ]; then
			echo "Midterm server is not up, sleeping..."
			sleep 4
		else
			break
		fi
	done
}

echo "Starting network provisioning script..."

clean_all
create_network
configure_vm
start_vm

echo "Network provisioning script finished."
