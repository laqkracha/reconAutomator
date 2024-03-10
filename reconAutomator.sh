#!/bin/bash

BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
NC=$(tput sgr0)

line_length=$(tput cols)

validate_ip() {
    local ip=$1
    local stat=1

    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        if [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]; then
            stat=0
        fi
    fi

    return $stat
}

echo -e "${YELLOW}
───────────╔══╗─╔╗────────╔╗
╔╦╦═╦═╦═╦═╦╣╔╗╠╦╣╚╦═╦══╦═╗║╚╦═╦╦╗
║╔╣╩╣═╣╬║║║║╠╣║║║╔╣╬║║║║╬╚╣╔╣╬║╔╝
╚╝╚═╩═╩═╩╩═╩╝╚╩═╩═╩═╩╩╩╩══╩═╩═╩╝${NC}"

resfile="results.txt"

echo "
───────────╔══╗─╔╗────────╔╗
╔╦╦═╦═╦═╦═╦╣╔╗╠╦╣╚╦═╦══╦═╗║╚╦═╦╦╗
║╔╣╩╣═╣╬║║║║╠╣║║║╔╣╬║║║║╬╚╣╔╣╬║╔╝
╚╝╚═╩═╩═╩╩═╩╝╚╩═╩═╩═╩╩╩╩══╩═╩═╩╝" >> $resfile

if [[ $(id -u) -ne 0 ]]; then
    echo -e "${RED}This script requires root privileges. Please run with sudo.${NC}"
    exit 1
fi

echo -e "${CYAN}What do you have for me? ip (i) / domain (d):${NC}"
read -r ip_domain

if [ "$ip_domain" == "i" ]; then
	echo -e "${CYAN}IP:${NC}"
	read -r ip
    if ! validate_ip "$ip"; then
        echo -e "${RED}Invalid IP address format. Please provide a valid IP address.${NC}"
        exit 1
    fi
	echo -e "${CYAN}Do you want to execute whois? (y/n):${NC}"
	read -r op
	echo -e "${CYAN}Do you want to execute dnsenum? (y/n):${NC}"
	read -r opdn
	echo -e "${CYAN}Do you want to do a tcp or udp scan? (tcp/udp/both):${NC}"
	read -r scantype
	if [[ -z "$ip" || -z "$op" || -z "$scantype" ]]; then
	    echo -e "${RED}I need you to give me all the values to work with${NC}"
    	exit 1
	else
        case "$op" in
            "y")
                if [[ "$opdn" == "y" ]]; then
                    sudo ./autoInfra.sh "$ip" wy dnsy "$scantype"
                else
                    sudo ./autoInfra.sh "$ip" wy dnsn "$scantype"
                fi
                ;;
            "n")
                if [[ "$opdn" == "y" ]]; then
                    sudo ./autoInfra.sh "$ip" wn dnsy "$scantype"
                else
                    sudo ./autoInfra.sh "$ip" wn dnsn "$scantype"
                fi
                ;;
            *)
                echo -e "${RED}There's an error, try again...${NC}"
                exit 1
                ;;
        esac
	fi

elif [ "$ip_domain" == "d" ]; then
	./autoDomain.sh
else
	exit 1
fi
