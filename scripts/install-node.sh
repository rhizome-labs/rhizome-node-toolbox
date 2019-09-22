installDependencies() {
	apt-get update
	apt-get install  -y systemd apt-transport-https ca-certificates curl gnupg-agent software-properties-common 
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	apt-get update
	apt-get -y install docker-ce docker-ce-cli containerd.io
	usermod -aG docker $(whoami)
	systemctl enable docker.service
	systemctl start docker.service
	apt-get install -y python-pip
	pip install docker-compose
}

formatDiskCheck(){
	echo "Below are the disks attached to your system."
	echo
	lsblk -d -no NAME
	echo
	echo "Which disk would you like to format and mount? (e.g. sdb)"
	read DEVICE_ID
	echo "What is the directory where you want to mount $DEVICE_ID to? (e.g. /mnt/disks/data1)"
	read MOUNT_POINT
}

formatDiskPrompt(){
	echo
	echo "Is the information below correct? (1 for yes, 2 for no.)"
	echo "DEVICE ID: $DEVICE_ID"
	echo "MOUNT POINT: $MOUNT_POINT"
	echo
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes ) formatDiskProcess; break;;
	        No ) formatDiskCheck; break;;
	    esac
	done
}

formatDiskProcess() {
	if [[ $(lsblk -no FSTYPE /dev/$DEVICE_ID) = ext4 ]];
	then
        echo "This disk is already formatted."
        exit
	else
		##FORMAT DISK
		#mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/$DEVICE_ID
		#mkdir -p $MOUNT_POINT
		#mount -o discard,defaults /dev/$DEVICE_ID $MOUNT_POINT
		#chmod -R a=r,a+X,u+w $MOUNT_POINT
		#chown root:root -R $MOUNT_POINT
		#cp /etc/fstab /etc/fstab.backup
		#echo UUID=`blkid -s UUID -o value /dev/$DEVICE_ID` $MOUNT_POINT ext4 discard,defaults,nofail 0 2 | tee -a /etc/fstab
		echo "Formatting now!"
	fi
}

formatDiskCheck
formatDiskPrompt
