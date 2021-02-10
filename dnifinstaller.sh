#!/bin/bash



function docker_check() {
	echo -e "[*]Installing docker \n"
	sudo apt-get remove docker docker-engine docker.io containerd runc &>/dev/null
	sudo apt-get install \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg-agent \
            software-properties-common &>/dev/null
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &>/dev/null 
	sudo apt-key fingerprint 0EBFCD88 &>/dev/null 
        sudo add-apt-repository \ 
         "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
         $(lsb_release -cs) \
         stable" &>/dev/null
	sudo apt-get -y update &>/dev/null
        sudo apt-get -y install docker-ce docker-ce-cli containerd.io &>/dev/null
        sleep 5
        sudo docker run hello-world &>/dev/null
        sleep 5
	sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose &>/dev/null
	sudo chmod +x /usr/local/bin/docker-compose 
        count=$(sysctl -n vm.max_map_count)
	if [ "$count" = "262144" ]; then
		echo -e "max count set"

	else

		echo -e "#memory & file settings
		fs.file-max=1000000
		vm.overcommit_memory=1
		vm.max_map_count=262144
		#n/w receive buffer
		net.core.rmem_default=33554432
		net.core.rmem_max=33554432" >>/etc/sysctl.conf

		sysctl -p
	fi

}



#echo -e "--------------------CALLING Docker------------------"

ARCH=$(uname -m)
VER=$(lsb_release -rs)


if [[ "$VER" = "20.04" ]] && [[ "$ARCH" = "x86_64" ]];  then # replace 18.04 by the number of release you want

       echo "Compatible version"
       #Copy your files here
       echo -e "* DNIF Installer for v9.1beta2"
       echo -e "** Please report issues to https://github.com/dnif-backyard/installer/issues**\n"
       echo -e "[*] Checking operating system for compatibility - DONE\n"
       echo -e "* Select a DNIF component you would like to install\n"
       echo -e "** for more information visit https://docs.dnif.it/v91/docs/high-level-dnif-architecture\n"
       echo -e "[1]- Core (CO) \n"
       echo -e "[2]- Data Node (DN) \n"
       echo -e "[3]- Adapter (AD) \n"
       echo -e "[4]- Local Console (LC) \n"
       echo -e "ENTER COMPONENT NAME:  \n "
       read -r COMP
       case "${COMP^^}" in
	       CO)
		       echo -e "[*] Installing the CORE \n"
		       sleep 2
		       echo -e "[*] Finding docker installation\n"
		       if [ -x "$(command -v docker)" ]; then
			       echo "[*]Updating Docker"
			       docker_check
			else
				echo -e "[*] Finding docker installation - NEGATIVE\n"
				echo -e "[*] Installaing Docker"
				docker_check
				echo -e "[*]Finding docker installation - DONE"
				echo -e "[*] Finding docker-compose - DONE"
			fi
			echo -e "[*] Pulling Docker Image for CORE"
			#docker pull dnif/core:v9beta2.2
			cd /
			sudo mkdir -p DNIF
			echo -e "Enter CORE IP:\c"
			read -r COIP
			sudo echo -e "version: "\'2.0\'"
services:
  core:
    image: dnif/core:v9beta2.2
    network_mode: "\'host\'"
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    volumes:
      - /CO:/dnif
      - /common:/common
      - /backup:/backup
    environment:
      - "\'CORE_IP="$COIP"\'"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    container_name: core-v9" >/DNIF/docker-compose.yml

			      cd /DNIF || exit
			      docker-compose up -d
			      ;;
		AD)
			echo -e "[*] Installing the ADAPTER \n"
			sleep 5
			echo -e "[*] Finding docker installation\n"
			if [ -x "$(command -v docker)" ]; then
				echo "[*] Updating Docker"
				docker_check
			else
				echo -e "[*] Finding docker installation - NEGATIVE\n"
				echo -e "[*] Installaing Docker"
				docker_check
				echo -e "[*]Finding docker installation - DONE"
				echo -e "[*] Finding docker-compose - DONE"
			fi
			echo -e "[*] Pulling Docker Image for Adapter"
			#docker pull dnif/adapter:v9beta2.2
			echo -e "ENTER CORE IP: \c"
			read -r COREIP
			cd /
			sudo mkdir -p /DNIF
			sudo mkdir -p /DNIF/AD
			sudo echo -e "version: "\'2.0\'"
services:
 adapter:
  image: dnif/adapter:v9beta2.2
  network_mode: "\'host\'"
  restart: unless-stopped
  cap_add:
   - NET_ADMIN
  environment:
   - "\'CORE_IP="$COREIP"\'"
  volumes:
   - /AD:/dnif
   - /backup:/backup
  container_name: adapter-v9" >/DNIF/AD/docker-compose.yaml
			  cd /DNIF/AD || exit
			  docker-compose up -d
			  ;;

		LC)
			echo -e "[*] Installing the Local Console \n"
			sleep 5
			echo -e "[*] Finding docker installation\n"
			if [ -x "$(command -v docker)" ]; then
				echo "[*] Updating Docker"
				docker_check
			else
				echo -e "[*] Finding docker installation - NEGATIVE\n"
				echo -e "[*] Installaing Docker"
				docker_check
				echo -e "[*]Finding docker installation - DONE"
				echo -e "[*] Finding docker-compose - DONE"
			fi
			#docker pull dnif/console:v9beta2.2
			echo -e "[*]Pulling Docker Image for Local Console"
			echo -e "ENTER INTERFACE NAME: \c"
			read -r INTERFACE
			cd /
			sudo mkdir -p /DNIF
			sudo mkdir -p /DNIF/LC
			sudo echo -e "version: "\'2.0\'"
services:
 console:
  image: dnif/console:v9beta2.2
  network_mode: "\'host\'"
  restart: unless-stopped
  cap_add:
   - NET_ADMIN
  environment:
   - "\'NET_INTERFACE="$INTERFACE"\'"
  volumes:
   - /dnif/LC:/dnif/lc
  container_name: console-v9" >/DNIF/LC/docker-compose.yaml
			  cd /DNIF/LC || exit
			  docker-compose up -d
			  ;;
		DN)
			echo -e "[*] Installing the DATA NODE \n"
			sleep 5
			echo -e "[*] Finding docker installation\n"
			if [ -x "$(command -v docker)" ]; then
				echo "[*] Updating Docker"
				docker_check
			else
				echo -e "[*] Finding docker installation - NEGATIVE\n"
				echo -e "[*] Installaing Docker"
				docker_check
				echo -e "[*]Finding docker installation - DONE"
				echo -e "[*] Finding docker-compose - DONE"
			fi
			echo -e "[*] Checking for JDK \n"
			if type -p java; then
				_java=java
			elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]]; then
				echo -e "\n\nfound java executable in $JAVA_HOME \n\n"
				_java="$JAVA_HOME/bin/java"
			else
				echo -e "\n To proceed futher you have to  Install openjdk11 before installtion\n\n"
				echo "To install OpenJdk11 type YES"
				read -r var
				if [ "$var" == "YES" ]; then
					apt-get install openjdk-11-jdk
				else
					echo "Aborted"
					exit 0
				fi
			fi
			if [[ "$_java" ]]; then
				version=$("$_java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
				if [[ "$version" == "11.0.8" ]]; then
					echo -e "\n OpenJdk $version version is running\n"
				fi
			fi
			sleep 5
			echo -e "[*]Pulling Docker Image for Data Node"
			#docker pull dnif/datanode:v9beta2.2
			echo -e "ENTER CORE IP: \c\n"
			read -r COREIP
			echo -e "\nENter INTERFACE NAME"
			read -r INTERFACE
			sudo mkdir -p /DNIF
			sudo mkdir -p /DNIF/DL
			sudo echo -e "version: "\'2\'"
services:
  datanode:
    privileged: true
    image: dnif/datanode:v9beta2
    network_mode: "\'host\'"
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    volumes:
      - /DL:/dnif
      - /run:/run
      - /opt:/opt
      - /etc/systemd/system:/etc/systemd/system
      - /common:/common
      - /backup:/backup
    environment:
      - "\'CORE_IP="$COREIP"\'"
      - "\'NET_INTERFACE="$INTERFACE"\'"
    ulimits:
      memlock:
        soft: -1
         hard: -1
    container_name: datanode-v9" >/DNIF/DL/docker-compose.yaml
			    cd /DNIF/DL || exit
			    docker-compose up -d
			    ;;
		esac

	



else
       echo "Non-compatible version"
fi

