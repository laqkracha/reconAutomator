#!/bin/bash

# Define color variables
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

echo "${YELLOW}
──────╔╗───╔══╗──╔═╗
─────╔╝╚╗──╚╣╠╝──║╔╝
╔══╦╗╠╗╔╬══╗║║╔═╦╝╚╦═╦══╗
║╔╗║║║║║║╔╗║║║║╔╬╗╔╣╔╣╔╗║
║╔╗║╚╝║╚╣╚╝╠╣╠╣║║║║║║║╔╗║
╚╝╚╩══╩═╩══╩══╩╝╚╩╝╚╝╚╝╚╝${NC}"

resfile="results.txt"

echo "
──────╔╗───╔══╗──╔═╗
─────╔╝╚╗──╚╣╠╝──║╔╝
╔══╦╗╠╗╔╬══╗║║╔═╦╝╚╦═╦══╗
║╔╗║║║║║║╔╗║║║║╔╬╗╔╣╔╣╔╗║
║╔╗║╚╝║╚╣╚╝╠╣╠╣║║║║║║║╔╗║
╚╝╚╩══╩═╩══╩══╩╝╚╩╝╚╝╚╝╚╝" >> "$resfile"

out1(){
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line"
}

out2(){
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"
    printf "%*s\n" $(((${#line}+$line_length)/2)) "$line" >> "$resfile"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"
}

contenum() {
    echo -e "${CYAN}Do you want me to try the Enumeration? (y/n)"
}

hostr() {
    text="xxxxxxxxxxxxxxxxxxxx Host xxxxxxxxxxxxxxxxxxxx"
    out1
    line="HOST"
    out2
    host "$1" | tee -a "$resfile"
    echo -e "${GREEN}host done, results.txt for more info${NC}"
}

whoisfunc() {
    text="xxxxxxxxxxxxxxxxxxxx Whois xxxxxxxxxxxxxxxxxxxx"
    out1
    line="WHOIS"
    out2
    whois "$1" >> "$resfile"
    echo -e "${GREEN}whois done, results.txt for more info${NC}"
}

hostup() {
    text="xxxxxxxxxxxxxxxxxxxx is the host up? xxxxxxxxxxxxxxxxxxxx"
    out1
    line="is the host up?"
    out2
    host_status=$(nmap -sn "$1" | grep -i "Host is up")

    if [ -n "$host_status" ]; then
        echo -e "${GREEN}Yep... Host is up${NC}"
        echo "$host_status" >> "$resfile"
    else
        echo -e "${RED}Maybe Windows Blocking ICMP...${NC}"
        host_status2=$(nmap "$1" -Pn | grep -i "open")
        if [ -n "$host_status2" ]; then
            echo -e "${GREEN}Yep, There are open ports for this ${BLUE}Windows host${NC}" # <-----------------------
            echo "Open ports for this Windows host" >> "$resfile"
        else
            echo -e "${RED}No ports open for this host${NC}"
            echo "No ports open for this host" >> "$resfile"
            echo -e "${RED}Host seems down...${NC}"
            echo "Host seems down..." >> "$resfile"
        fi
    fi
}

port_service_scan() {
    text="xxxxxxxxxxxxxxxxxxxx Ports & Service Scan xxxxxxxxxxxxxxxxxxxx"
    out1
    line="Ports & Service Scan"
    out2
    nmap_res=$(sudo nmap "$1" -sV | tail -n +4 | head -n -2)
    echo "$nmap_res" >> "$resfile"
    echo -e "${MAGENTA}Nmap done, remember that these results are just for common ports.${NC}"
    echo -e "${MAGENTA}For further information, check out results.txt${NC}"

    if grep -qi "21/tcp    open" <<< "$nmap_res"; then
        echo -e "${GREEN}FTP port is open!${NC}"
        contenum
        read op
        if [[ "$op" == "y" ]]; then
            sudo ./autoEnum.sh.sh "$1" tcp 21
        elif [[ "$op" == "n" ]]; then
            echo -e "${CYAN}OK, bye..."
            exit 1
        else
            echo "${RED}Invalid option${NC}"
            exit 1
        fi
    else
        echo -e "${RED}FTP port is not open.${NC}"
    fi

    if grep -qi "22/tcp    open" <<< "$nmap_res"; then
        echo -e "${GREEN}SSH port is open!${NC}"
        contenum
        read op
        if [[ "$op" == "y" ]]; then
            sudo ./autoEnum.sh.sh "$1" tcp 22
        elif [[ "$op" == "n" ]]; then
            echo -e "${CYAN}OK, bye..."
            exit 1
        else
            echo "${RED}Invalid option${NC}"
            exit 1
        fi
    else
        echo -e "${RED}SSH port is not open.${NC}"
    fi

    if grep -qi "25/tcp    open" <<< "$nmap_res"; then
        echo -e "${GREEN}SMTP port is open!${NC}"
        contenum
        read op
        if [[ "$op" == "y" ]]; then
            sudo ./autoEnum.sh "$1" tcp 25
        elif [[ "$op" == "n" ]]; then
            echo -e "${CYAN}OK, bye..."
            exit 1
        else
            echo "${RED}Invalid option${NC}"
            exit 1
        fi
    else
        echo -e "${RED}SMTP port 25 is not open.${NC}"
    fi

    if grep -qi "53/tcp    open" <<< "$nmap_res"; then
        echo -e "${GREEN}DNS port is open!${NC}"
        contenum
        read op
        if [[ "$op" == "y" ]]; then
            sudo ./autoEnum.sh "$1" tcp 53
        elif [[ "$op" == "n" ]]; then
            echo -e "${CYAN}OK, bye..."
            exit 1
        else
            echo "${RED}Invalid option${NC}"
            exit 1
        fi
    else
        echo -e "${RED}DNS port is not open.${NC}"
    fi

    if grep -qi "80/tcp    open" <<< "$nmap_res"; then
        echo -e "${GREEN}HTTP port is open!${NC}"
        contenum
        read op
        if [[ "$op" == "y" ]]; then
            sudo ./autoEnum.sh "$1" tcp 80
        elif [[ "$op" == "n" ]]; then
            echo -e "${CYAN}OK, bye..."
            exit 1
        else
            echo "${RED}Invalid option${NC}"
            exit 1
        fi
    else
        echo -e "${RED}HTTP port is not open.${NC}"
    fi

    if grep -qi "110/tcp    open" <<< "$nmap_res"; then
        echo -e "${GREEN}IMAP/POP3 port is open!${NC}"
        contenum
        read op
        if [[ "$op" == "y" ]]; then
            sudo ./autoEnum.sh "$1" tcp 110
        elif [[ "$op" == "n" ]]; then
            echo -e "${CYAN}OK, bye..."
            exit 1
        else
            echo "${RED}Invalid option${NC}"
            exit 1
        fi
    else
        echo -e "${RED}IMAP/POP3 port 110 is not open.${NC}"
    fi

    if grep -qi "137/tcp    open" <<< "$nmap_res"; then
        echo -e "${GREEN}SMB port is open! - NetBios${NC}"
        contenum
        read op
        if [[ "$op" == "y" ]]; then
            sudo ./autoEnum.sh "$1" tcp 137
        elif [[ "$op" == "n" ]]; then
            echo -e "${CYAN}OK, bye..."
            exit 1
        else
            echo "${RED}Invalid option${NC}"
            exit 1
        fi
    else
        echo -e "${RED}SMB port 137 is not open.${NC}"
    fi

    if grep -qi "138/tcp    open" <<< "$nmap_res"; then
        echo -e "${GREEN}SMB port is open! - NetBios${NC}"
        contenum
        read op
        if [[ "$op" == "y" ]]; then
            sudo ./autoEnum.sh "$1" tcp 138
        elif [[ "$op" == "n" ]]; then
            echo -e "${CYAN}OK, bye..."
            exit 1
        else
            echo "${RED}Invalid option${NC}"
            exit 1
        fi
    else
        echo -e "${RED}SMB port 138 is not open.${NC}"
    fi

    if grep -qi "139/tcp    open" <<< "$nmap_res"; then
        echo -e "${GREEN}SMB port is open! - NetBios${NC}"
        contenum
        read op
        if [[ "$op" == "y" ]]; then
            sudo ./autoEnum.sh "$1" tcp 139
        elif [[ "$op" == "n" ]]; then
            echo -e "${CYAN}OK, bye..."
            exit 1
        else
            echo "${RED}Invalid option${NC}"
            exit 1
        fi
    else
        echo -e "${RED}SMB port 139 is not open.${NC}"
    fi

    if grep -qi "143/tcp    open" <<< "$nmap_res"; then
        echo -e "${GREEN}IMAP/POP3 port is open!${NC}"
        contenum
        read op
        if [[ "$op" == "y" ]]; then
            sudo ./autoEnum.sh "$1" tcp 143
        elif [[ "$op" == "n" ]]; then
            echo -e "${CYAN}OK, bye..."
            exit 1
        else
            echo "${RED}Invalid option${NC}"
            exit 1
        fi
    else
        echo -e "${RED}IMAP/POP3 port 143 is not open.${NC}"
    fi


    if grep -qi "445/tcp    open" <<< "$nmap_res"; then
        echo -e "${GREEN}SMB port is open! - CIFS${NC}"
        contenum
        read op
        if [[ "$op" == "y" ]]; then
            sudo ./autoEnum.sh "$1" tcp 445
        elif [[ "$op" == "n" ]]; then
            echo -e "${CYAN}OK, bye..."
            exit 1
        else
            echo "${RED}Invalid option${NC}"
            exit 1
        fi
    else
        echo -e "${RED}SMB port is not open.${NC}"
    fi

    if grep -qi "587/tcp    open" <<< "$nmap_res"; then
        echo -e "${GREEN}SMTP port is open!${NC}"
        contenum
        read op
        if [[ "$op" == "y" ]]; then
            sudo ./autoEnum.sh "$1" tcp 587
        elif [[ "$op" == "n" ]]; then
            echo -e "${CYAN}OK, bye..."
            exit 1
        else
            echo "${RED}Invalid option${NC}"
            exit 1
        fi
    else
        echo -e "${RED}SMTP port 587 is not open.${NC}"
    fi

    if grep -qi "993/tcp    open" <<< "$nmap_res"; then
        echo -e "${GREEN}IMAP/POP3 port is open!${NC}"
        contenum
        read op
        if [[ "$op" == "y" ]]; then
            sudo ./autoEnum.sh "$1" tcp 993
        elif [[ "$op" == "n" ]]; then
            echo -e "${CYAN}OK, bye..."
            exit 1
        else
            echo "${RED}Invalid option${NC}"
            exit 1
        fi
    else
        echo -e "${RED}IMAP/POP3 port 993 SSL/TLS is not open.${NC}"
    fi

    if grep -qi "995/tcp    open" <<< "$nmap_res"; then
        echo -e "${GREEN}IMAP/POP3 port is open!${NC}"
        contenum
        read op
        if [[ "$op" == "y" ]]; then
            sudo ./autoEnum.sh "$1" tcp 995
        elif [[ "$op" == "n" ]]; then
            echo -e "${CYAN}OK, bye..."
            exit 1
        else
            echo "${RED}Invalid option${NC}"
            exit 1
        fi
    else
        echo -e "${RED}IMAP/POP3 port 995 SSL/TLS is not open.${NC}"
    fi

    if grep -qi "2049/tcp    open" <<< "$nmap_res"; then
        echo -e "${GREEN}NFS port is open!${NC}"
        contenum
        read op
        if [[ "$op" == "y" ]]; then
            sudo ./autoEnum.sh "$1" tcp 2049
        elif [[ "$op" == "n" ]]; then
            echo -e "${CYAN}OK, bye..."
            exit 1
        else
            echo "${RED}Invalid option${NC}"
            exit 1
        fi
    else
        echo -e "${RED}NFS port is not open.${NC}"
    fi

    
    if grep -qi "3306/tcp    open" <<< "$nmap_res"; then
        echo -e "${GREEN}MySQL port is open!${NC}"
        contenum
        read op
        if [[ "$op" == "y" ]]; then
            sudo ./autoEnum.sh "$1" tcp 3306
        elif [[ "$op" == "n" ]]; then
            echo -e "${CYAN}OK, bye..."
            exit 1
        else
            echo "${RED}Invalid option${NC}"
            exit 1
        fi
    else
        echo -e "${RED}MySQL port is not open.${NC}"
    fi
    if grep -qi "1433/tcp    open" <<< "$nmap_res"; then
        echo -e "${GREEN}SSQL port is open!${NC}"
        contenum
        read op
        if [[ "$op" == "y" ]]; then
            sudo ./autoEnum.sh "$1" tcp 1433
        elif [[ "$op" == "n" ]]; then
            echo -e "${CYAN}OK, bye..."
            exit 1
        else
            echo "${RED}Invalid option${NC}"
            exit 1
        fi
    else
        echo -e "${RED}SSQL port is not open.${NC}"
    fi
}

dnsenumfunc() {
    text="xxxxxxxxxxxxxxxxxxxx DNSenum xxxxxxxxxxxxxxxxxxxx"
    out1
    line="dnsenum"
    out2
    dnsenum "$1" | tee -a "$resfile"
    echo -e "${GREEN}DNSenum done, results.txt for more info${NC}"
}

# Check for root privileges
if [[ $(id -u) -ne 0 ]]; then
    echo -e "${RED}This script requires root privileges. Please run with sudo.${NC}"
    exit 1
fi

# Options for the infra script
if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" ]]; then
    echo -e "${RED}Usage: ./reconAutomator.sh <IP> <whois wy/wn> <dnsenum dnsy/dnsn> <tcp/udp/both>${NC}"
    exit 1
else
    hostr "$1"

    if [[ "$2" == "wy" ]]; then
        whoisfunc "$1"
    fi

    if [[ "$3" == "dnsy" ]]; then
        dnsenumfunc "$1"
    fi

    if [[ "$4" == "tcp" || "$4" == "both" ]]; then
        hostup "$1"
        port_service_scan "$1"
        echo -e "${MAGENTA}ALL DONE... see the results in the results.txt file${NC}"
        exit 1
    elif [[ "$4" == "udp" ]]; then
        # udp functions
        echo -e "${MAGENTA}ALL DONE... see the results in the results.txt file${NC}"
        exit 1
    else
        echo -e "${RED}Invalid protocol. Please provide either 'tcp', 'udp', or 'both' as the fourth argument.${NC}"
        exit 1
    fi
fi
