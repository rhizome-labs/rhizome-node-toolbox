#Declare functions used in script.
formatDisk(){
	echo -e "${YELLOW}Below are the disks attached to your system.${NC}"
	echo
	lsblk -d -o NAME,SIZE,MOUNTPOINT
	echo
	echo -e "${YELLOW}Which disk would you like to format and mount? (e.g. sdb)${NC}"
	read DEVICE_ID
	echo -e "${YELLOW}What is the directory where you want to mount $DEVICE_ID to? (e.g. /mnt/disks/data1)${NC}"
	read MOUNT_POINT
	echo
	echo -e "${YELLOW}Is the information below correct? (1 for yes, 2 for no.)${NC}"
	echo "DEVICE ID: $DEVICE_ID"
	echo "MOUNT POINT: $MOUNT_POINT"
	echo
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes )
				#If user answers "Yes", move on to formatDiskProcess().
				formatDiskProcess;
				break;;
	        No )
				#If user answers "No", rerun formatDisk().
				formatDisk;
				break;;
	    esac
	done
}

formatDiskProcess() {
	#Check if disk is already formatted. The format set for this check is ext4.
	if [[ $(lsblk -no FSTYPE /dev/$DEVICE_ID) = ext4 ]];
	then
		#If disk is already formatted, alert user and return to main menu.
        echo "This disk is already formatted."
        echo "Returning to main menu..."
        sleep 2
        rhizomeToolbox
	else
		mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/$DEVICE_ID
		mkdir -p $MOUNT_POINT
		mount -o discard,defaults /dev/$DEVICE_ID $MOUNT_POINT
		chmod -R a=r,a+X,u+w $MOUNT_POINT
		chown root:root -R $MOUNT_POINT
		cp /etc/fstab /etc/fstab.backup
		echo UUID=`blkid -s UUID -o value /dev/$DEVICE_ID` $MOUNT_POINT ext4 discard,defaults,nofail 0 2 | tee -a /etc/fstab
	fi
}

installNodeDependencies() {
	#Install dependencies for citizen node.
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

installHAProxy() {
	#Install HAProxy
	apt-get update
	apt-get install -y haproxy
	systemctl enable haproxy.service
	systemctl start haproxy.service
	rm -rf /etc/haproxy/haproxy.cfg
	curl -o /etc/haproxy/haproxy.cfg https://raw.githubusercontent.com/rhizomeicx/rhizome-node-toolbox/master/prep/haproxy.cfg > /dev/null 2>&1
	curl -o /etc/haproxy/whitelist.lst https://raw.githubusercontent.com/rhizomeicx/rhizome-node-toolbox/master/misc/whitelist.lst > /dev/null 2>&1
	service haproxy restart
}

installCitizenNode(){
	echo
	echo -e "${YELLOW}In order to proceed, please select an installation mode."
	echo -e "- Easy mode will create an icon user, and install the citizen node in /home/icon/citizen."
	echo -e "- Advanced mode allows you to specify the installation path.${NC}"
	echo
	select opt in "Easy" "Advanced"; do
	    case $opt in
	        Easy )
				createICONUser;
				installCitizenNodeEasy;
				break;;
	        Advanced )
				createICONUser;
				installCitizenNodeAdvanced;
				break;;
	    esac
	done
	#wget -o https://raw.githubusercontent.com/rhizomeicx/rhizome-node-toolbox/master/citizen/default/docker-compose.yml
}

installCitizenNodeEasy(){
	#Install citizen node dependencies.
	installNodeDependencies
	#Create directory for citizen node.
	mkdir -p /home/icon/citizen
	##Download docker-compose.yml.
	curl -o /home/icon/citizen/docker-compose.yml https://raw.githubusercontent.com/rhizomeicx/rhizome-node-toolbox/master/citizen/default/docker-compose.yml > /dev/null 2>&1
	#Download rc.local.
	curl -o /etc/rc.local https://raw.githubusercontent.com/rhizomeicx/rhizome-node-toolbox/master/scripts/rc.local > /dev/null 2>&1
	chmod +x /etc/rc.local
	#Permissions reset
	chmod -R a=r,a+X,u+w /home/icon
	chown icon:icon -R /home/icon
	chmod -R a=r,a+X,u+w /home/icon/citizen
	chown icon:icon -R /home/icon/citizen
	#Add icon to docker group.
	usermod -aG docker icon
	#START DOCKER IMAGE
	cd /home/icon/citizen && docker-compose up -d
	sleep 2
	echo "Installation is finished!"
	echo "Returning to main menu..."
	sleep 2
	rhizomeToolbox
}

installCitizenNodeAdvanced(){
	echo -e "${YELLOW}What directory would you like to install the ICON citizen node to? (e.g. /mnt/disks/data1/citizen)${NC}"
	read CTZ_INSTALL_DIR
	#Install citizen node dependencies.
	installNodeDependencies
	#Create directory for citizen node.
	mkdir -p $CTZ_INSTALL_DIR
	ln -s $CTZ_INSTALL_DIR /home/icon
	##Download docker-compose.yml.
	curl -o $CTZ_INSTALL_DIR/docker-compose.yml https://raw.githubusercontent.com/rhizomeicx/rhizome-node-toolbox/master/citizen/default/docker-compose.yml > /dev/null 2>&1
	#Download rc.local.
	curl -o /etc/rc.local https://raw.githubusercontent.com/rhizomeicx/rhizome-node-toolbox/master/scripts/rc.local > /dev/null 2>&1
	chmod +x /etc/rc.local
	#Permissions reset
	chmod -R a=r,a+X,u+w /home/icon
	chown icon:icon -R /home/icon
	chmod -R a=r,a+X,u+w $CTZ_INSTALL_DIR
	chown icon:icon -R $CTZ_INSTALL_DIR
	#Add icon to docker group.
	usermod -aG docker icon
	#START DOCKER IMAGE
	cd $CTZ_INSTALL_DIR && docker-compose up -d
	sleep 2
	echo "Installation is finished!"
	echo "Returning to main menu..."
	sleep 2
	rhizomeToolbox
}

installPRepNode(){
	echo
	echo -e "${YELLOW}In order to proceed, please select an installation mode."
	echo -e "- Easy mode will create an icon user, and install the P-Rep node in /home/icon/prep."
	echo -e "- Advanced mode allows you to specify the installation path.${NC}"
	echo
	select opt in "Easy" "Advanced"; do
	    case $opt in
	        Easy )
				createICONUser;
				installPRepNodeEasy;
				break;;
	        Advanced )
				createICONUser;
				installPRepNodeAdvanced;
				break;;
	    esac
	done
	#wget -o https://raw.githubusercontent.com/rhizomeicx/rhizome-node-toolbox/master/citizen/default/docker-compose.yml
}

installPRepNodeEasy(){
	#Install P-Rep dependencies.
	installNodeDependencies
	#Create directory for P-Rep node.
	mkdir -p /home/icon/prep
	##Download docker-compose.yml.
	curl -o /home/icon/prep/docker-compose.yml https://raw.githubusercontent.com/rhizomeicx/rhizome-node-toolbox/master/prep/docker-compose.yml > /dev/null 2>&1
	#Download rc.local.
	curl -o /etc/rc.local https://raw.githubusercontent.com/rhizomeicx/rhizome-node-toolbox/master/scripts/rc.local > /dev/null 2>&1
	chmod +x /etc/rc.local
	#Permissions reset
	chmod -R a=r,a+X,u+w /home/icon
	chown icon:icon -R /home/icon
	chmod -R a=r,a+X,u+w /home/icon/prep
	chown icon:icon -R /home/icon/prep
	#Add icon to docker group.
	usermod -aG docker icon
	#START DOCKER IMAGE
	#cd /home/icon/prep && docker-compose up -d
	sleep 2
	echo "Installation is finished!"
	sleep 2
	echo "Please add keystore file and password to docker-compose.yml and start the Docker image."
	sleep 2
	echo "Returning to main menu..."
	sleep 2
	rhizomeToolbox
}

installPRepNodeAdvanced(){
	echo -e "${YELLOW}What directory would you like to install the ICON P-Rep node to? (e.g. /mnt/disks/data1/prep)${NC}"
	read PREP_INSTALL_DIR
	#Install citizen node dependencies.
	installNodeDependencies
	#Create directory for citizen node.
	mkdir -p $PREP_INSTALL_DIR
	#Make symlink to home folder of "icon" user.
	ln -s $PREP_INSTALL_DIR /home/icon
	#Download rc.local.
	curl -o /etc/rc.local https://raw.githubusercontent.com/rhizomeicx/rhizome-node-toolbox/master/scripts/rc.local > /dev/null 2>&1
	chmod +x /etc/rc.local
	#Download docker-compose.yml.
	curl -o /home/icon/prep/docker-compose.yml https://raw.githubusercontent.com/rhizomeicx/rhizome-node-toolbox/master/prep/docker-compose.yml > /dev/null 2>&1
	chmod -R a=r,a+X,u+w /home/icon
	chown icon:icon -R /home/icon
	chmod -R a=r,a+X,u+w $PREP_INSTALL_DIR
	chown icon:icon -R $PREP_INSTALL_DIR
	#Add icon to docker group.
	usermod -aG docker icon
	#START DOCKER IMAGE
	#cd PREP_INSTALL_DIR && docker-compose up -d
	sleep 2
	echo "Installation is finished!"
	sleep 2
	echo "Please add keystore file and password to docker-compose.yml and start the Docker image."
	sleep 2
	echo "Returning to main menu..."
	sleep 2
	rhizomeToolbox
}

createICONUser(){
	#Declare icon user and create random password.
	ICONPASSWORD=$(</dev/urandom tr -dc _A-Z-a-z-0-9 | head -c12)
	ICONUSERNAME="icon"
	#Check if icon user already exists.
	if id -u "$ICONUSERNAME" >/dev/null 2>&1; then
	    echo "This user already exists."
	#Create icon user if it doesn't exist.
	else
	    useradd -m -p $ICONPASSWORD -s /bin/bash $ICONUSERNAME
	    usermod -a -G sudo $ICONUSERNAME
	    echo $ICONUSERNAME:$ICONPASSWORD | chpasswd
	    confirmUserPassword;
	fi
}

confirmUserPassword(){
	#Confirm user has stored password.
	echo "The icon user has been created successfully."
	echo -e "${RED}Username: icon${NC}"
	echo -e "${RED}Password: $ICONPASSWORD${NC}"
	echo
	read -p "Please store the login credentials above in a secure location, and type kbbq to continue."$'\n' -n 4 -r
	echo
	if [[ $REPLY =~ ^kbbq$ ]]
	then
		return
   	else
    		confirmUserPassword
	fi 
}

rhizomeToolbox() {
echo
echo -e "${YELLOW}RHIZOME Toolbox v1.0${NC}"
echo
PS3=$'\n''RHIZOME Toolbox v0.2> '
options=("Format and Mount Disk" "Install Citizen Node" "Install P-Rep Node" "Update Node Image" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Format and Mount Disk")
            formatDisk;
            break;;
        "Install Citizen Node")
			installNodeDependencies;
			installHAProxy;
            installCitizenNode;
            break;;
        "Install P-Rep Node")
            installNodeDependencies;
            installHAProxy;
            installPRepNode;
            break;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
}

#Global color declarations.
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

#Run the script!
rhizomeToolbox
