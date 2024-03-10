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

echo -e "${YELLOW}
──────╔╗───╔═══╗
─────╔╝╚╗──╚╗╔╗║
╔══╦╗╠╗╔╬══╗║║║╠══╦╗╔╦══╦╦═╗
║╔╗║║║║║║╔╗║║║║║╔╗║╚╝║╔╗╠╣╔╗╗
║╔╗║╚╝║╚╣╚╝╠╝╚╝║╚╝║║║║╔╗║║║║║
╚╝╚╩══╩═╩══╩═══╩══╩╩╩╩╝╚╩╩╝╚╝${NC}"

resfile="results.txt"

echo "
──────╔╗───╔═══╗
─────╔╝╚╗──╚╗╔╗║
╔══╦╗╠╗╔╬══╗║║║╠══╦╗╔╦══╦╦═╗
║╔╗║║║║║║╔╗║║║║║╔╗║╚╝║╔╗╠╣╔╗╗
║╔╗║╚╝║╚╣╚╝╠╝╚╝║╚╝║║║║╔╗║║║║║
╚╝╚╩══╩═╩══╩═══╩══╩╩╩╩╝╚╩╩╝╚╝" >> $resfile

dnsreconfunc() {
    text="xxxxxxxxxxxxxxxxxxxx DNSrecon xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line"
    line="DNSrecon"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"
    printf "%*s\n" $(((${#line}+$line_length)/2)) "$line" >> "$resfile"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"

    dnsrecon -d "$1" >> "$resfile"
    echo -e "${GREEN}dnsrecon done, results.txt for more info${NC}"
}

wafwoof() {
    line="Wafw00f"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"
    printf "%*s\n" $(((${#line}+$line_length)/2)) "$line" >> "$resfile"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"
    sudo wafw00f "$1" | tee -a "$resfile"
    echo -e "${GREEN}wafw00f done, results.txt for more info${NC}"
}

sublisterfunc() {
    text="xxxxxxxxxxxxxxxxxxxx Sublist3r xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line"
    line="Sublist3r"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"
    printf "%*s\n" $(((${#line}+$line_length)/2)) "$line" >> "$resfile"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"

    sudo python3 ~/tools/Sublist3r/sublist3r.py -d "$1" >> "$resfile"
    echo -e "${GREEN}sublist3r done, results.txt for more info${NC}"
}

theharvester(){
    text="xxxxxxxxxxxxxxxxxxxx theHarvester xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line"
    line="theHarvester"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"
    printf "%*s\n" $(((${#line}+$line_length)/2)) "$line" >> "$resfile"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"

    python3 ~/theHarvester/theHarvester.py "$1" >> "$resfile"
    echo -e "${GREEN}theHarvester done, results.txt for more info${NC}"
}

whatwebfunc(){
    text="xxxxxxxxxxxxxxxxxxxx whatweb xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line"
    line="Whatweb"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"
    printf "%*s\n" $(((${#line}+$line_length)/2)) "$line" >> "$resfile"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"

    sudo whatweb "$1" >> "$resfile"
    echo -e "${GREEN}whatweb done, results.txt for more info${NC}"
}

############ Shodan/Censys functionality

passiverecon(){
    whatwebfunc "$1"
    wafwoof "$1"
    dnsreconfunc "$1"
    theharvester "$1"
    sublisterfunc "$1"
    echo -e "${MAGENTA}ALL DONE... see the results in the results.txt file${NC}"
    exit 1
}

activerecon(){
    echo -e "${BLUE}Running ./autoInfra.sh reconnaissance...${NC}"
    sudo ./autoInfra.sh 
}

if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
    echo -e "${RED}Usage: ./autoDomain.sh <ip/domain> <activeRecon y/n>${NC}"
    exit -1
else
    if [[ ("$2" == "y")  ]]; then
        passiverecon "$1"
        activerecon
    elif [[ ("$2" == "n") ]]; then
        passiverecon "$1"
    else
        echo -e "${RED}There's an error... try again${NC}"
    fi
fi
