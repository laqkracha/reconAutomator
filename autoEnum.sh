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
─────╔╝╚╗──║╔══╝
╔══╦╗╠╗╔╬══╣╚══╦═╗╔╗╔╦╗╔╗
║╔╗║║║║║║╔╗║╔══╣╔╗╣║║║╚╝║
║╔╗║╚╝║╚╣╚╝║╚══╣║║║╚╝║║║║
╚╝╚╩══╩═╩══╩═══╩╝╚╩══╩╩╩╝${NC}"

resfile="results.txt"
symbol="!"

echo "
──────╔╗───╔═══╗
─────╔╝╚╗──║╔══╝
╔══╦╗╠╗╔╬══╣╚══╦═╗╔╗╔╦╗╔╗
║╔╗║║║║║║╔╗║╔══╣╔╗╣║║║╚╝║
║╔╗║╚╝║╚╣╚╝║╚══╣║║║╚╝║║║║
╚╝╚╩══╩═╩══╩═══╩╝╚╩══╩╩╩╝" >> $resfile


ftpf() {
    line="FTP ENUM"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"
    printf "%*s\n" $(((${#line}+$line_length)/2)) "$line" >> "$resfile"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"
    echo -e "${CYAN}Trying to login as anonymous...${NC}" | tee -a $resfile

    nmap_res=$(nmap "$1" -p 21 --script ftp-anon | tail -n +4 | head -n -2)
    echo "$nmap_res" >> "$resfile"
    
    if grep -qi "Anonymous FTP login allowed" <<< "$nmap_res"; then
        echo -e "${GREEN}Anonymous FTP login successful.${NC}"
    else
        echo -e "${RED}Failed to login as anonymous.${NC}"
        echo -e "${CYAN}Do you want to try brute-forcing? [y/n]${NC}"
        read op
        echo -e "${CYAN}Against which user or uselist?${NC}"
        read usrlst
        if [[ "$op" == "y" ]]; then
            text="xxxxxxxxxxxxxxxxxxxx ftp-brute xxxxxxxxxxxxxxxxxxxx"
            padding=$(( (line_length - ${#text}) / 2 ))
            line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
            echo "$line" | tee -a $resfile
            nmaps=$(nmap "$1" --script ftp-brute --script-args userdb="$usrlst" -p 21 | tail -n +4 | head -n -2)
            echo "$nmaps" >> "$resfile"

            if grep -qi "Valid credentials" <<< "$nmaps"; then
                echo -e "${GREEN}FTP brute-force success.${NC}"
                echo "$nmaps" | grep -qi "Valid credentials"
            else
                echo -e "${RED}Failed to brute-force FTP.${NC}"
            fi
        elif [[ "$op" == "n" ]]; then
            echo -e "${WHITE}Skipped...${NC}" | tee -a $resfile
        else
            echo -e "${RED}Invalid option.${NC}"
        fi
    fi
    echo -e "${GREEN}FTP enumeration done. Check results.txt for more info.${NC}"
}

sshf() {
    line="SSH ENUM"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"
    printf "%*s\n" $(((${#line}+$line_length)/2)) "$line" >> "$resfile"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"
    text="xxxxxxxxxxxxxxxxxxxx ssh2-enum-algos xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
   	nmap "$1" -p22 --script ssh2-enum-algos | tee -a $resfile
   	echo "${GREEN}ssh2-enum-algos done${NC}"
    text="xxxxxxxxxxxxxxxxxxxx ssh-hostkey xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
   	echo -e "${CYAN}Give me the path to the user list or just the specific user${NC}"
    read usrlst
   	nmaps=$(nmap "$1" -p22 --script ssh-hostkey --script-args="ssh.user=$usrlst")
   	echo "$nmaps" >> $resfile
   	if grep -qi "none_auth" <<< "$nmap_res"; then
        echo -e "${GREEN}none_auth found.${NC}"
        echo "$nmap_res" | grep -qi "none_auth"
    else
    	echo -e "${BLUE}For more info check results.txt${NC}"
    fi
   	echo "${GREEN}ssh-hostkey done${NC}"
    echo -e "${WHITE}------------- ssh-auth-methods -------------${NC}" | tee -a $resfile
    text="xxxxxxxxxxxxxxxxxxxx ssh-auth-methods xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
   	echo -e "${CYAN}Give me the path to the user list or just the specific user${NC}"
    read usrlst
   	nmaps=$(nmap "$1" -p 22 --script ssh-auth-methods --script-args="ssh.user=$usrlst" | tail -n +4 | head -n -2)
   	echo "$nmaps" >> $resfile
   	if grep -qi "Supported authentication" <<< "$nmap_res"; then
        echo -e "${GREEN}Auth methods done.${NC}"
    else
    	echo -e "${RED}Not able to find the auth methods${NC}"
    fi
   	echo "${GREEN}ssh-auth-methods done${NC}"
   	echo -e "${CYAN}Do you want to try brute-forcing? [y/n]${NC}"
        read op
        echo -e "${CYAN}Give me the path to the user list or just the specific user${NC}"
        read usrlst
        if [[ "$op" == "y" ]]; then
            text="xxxxxxxxxxxxxxxxxxxx ssh-brute xxxxxxxxxxxxxxxxxxxx"
            padding=$(( (line_length - ${#text}) / 2 ))
            line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
            echo "$line" | tee -a $resfile
            nmaps=$(nmap "$1" -p 22 --script ssh-brute --script-args userdb="$usrlst" | tail -n +4 | head -n -2)
            echo "$nmaps" >> "$resfile"
            if grep -qi "Accounts" <<< "$nmaps"; then
                echo -e "${GREEN}SSH brute-force success.${NC}"
                echo "$nmaps" | grep "credentials"
            else
                echo -e "${RED}Failed to brute-force SSH.${NC}"
            fi
        elif [[ "$op" == "n" ]]; then
            echo -e "${WHITE}Skipped...${NC}" | tee -a $resfile
        else
            echo -e "${RED}Invalid option.${NC}"
        fi
        echo -e "${GREEN}SSH enumeration done. Check results.txt for more info.${NC}"
}

httpf() {
    line="HTTP ENUM"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"
    printf "%*s\n" $(((${#line}+$line_length)/2)) "$line" >> "$resfile"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile" 
    text="xxxxxxxxxxxxxxxxxxxx whatweb xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    whatweb "$1" | tee -a $resfile
    echo "${GREEN}whatweb done${NC}" 
    text="xxxxxxxxxxxxxxxxxxxx dirb xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    echo -e "${CYAN}Do you want to try to find directories with dirb? [y/n]${NC}"
    read op
    if [[ "$op" == "y" ]]; then
        echo -e "${CYAN}Do you want to run it with the default list or another? [y/a]${NC}"
        read opd
        if [[ "$opd" == "a" ]]; then
            echo -e "${CYAN}Please give me the path to the directory list:${NC}"
            read pdl
            dirb http://"$1" "$pdl" | tee -a $resfile
        else
            echo -e "${WHITE}Skipped...${NC}" | tee -a $resfile
            dirb http://"$1" | tee -a $resfile
        fi
    elif [[ "$op" == "n" ]]; then
        echo -e "${WHITE}Skipped...${NC}" | tee -a $resfile
    else
        echo -e "${RED}Invalid option.${NC}"
    fi
    text="xxxxxxxxxxxxxxxxxxxx HTTP NMAP SCRIPTS xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    text="xxxxxxxxxxxxxxxxxxxx http-enum xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -sV -p80 --script http-enum | tee -a $resfile
    text="xxxxxxxxxxxxxxxxxxxx http-headers xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -sV -p80 --script http-headers | tee -a $resfile
    text="xxxxxxxxxxxxxxxxxxxx http-methods xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -sV -p80 --script http-methods | tee -a $resfile
    text="xxxxxxxxxxxxxxxxxxxx http-webdav-scan xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    echo -e "${CYAN}Do you want to check for WEBDAV in some directory? [y/n]"
    read wbdvop
    if [[ "$wbdvop" == "y" ]]; then
        echo -e "${CYAN}Give me the url-path you want to test${NC}"
        read url_path
        nmap "$1" -sV -p80 --script http-webdav-scan --script-args http-methods.url-path="$url_path" | tee -a $resfile        
    else
        echo -e "${WHITE}Skipped...${NC}" | tee -a $resfile
    fi
    echo -e "${GREEN}HTTP enumeration done. Check results.txt for more info.${NC}"
}

smblogged() {
    text="xxxxxxxxxxxxxxxxxxxx smb-enum-shares xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p445 --script smb-enum-shares --script-args smbusername="$username",smbpassword="$passwd"| tee -a $resfile

    text="xxxxxxxxxxxxxxxxxxxx smb-enum-users xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p445 --script smb-enum-users --script-args smbusername="$username",smbpassword="$passwd"| tee -a $resfile

    echo -e "${WHITE}------------- trying smb-enum-stats with the provided creds -------------${NC}"
    text="xxxxxxxxxxxxxxxxxxxx smb-enum-stats xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p445 --script smb-enum-stats --script-args smbusername="$username",smbpassword="$passwd"| tee -a $resfile

    echo -e "${WHITE}------------- trying smb-enum-domains with the provided creds -------------${NC}"
    text="xxxxxxxxxxxxxxxxxxxx smb-enum-domains xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p445 --script smb-enum-domains --script-args smbusername="$username",smbpassword="$passwd"| tee -a $resfile

    echo -e "${WHITE}------------- trying smb-enum-groups with the provided creds -------------${NC}"
    text="xxxxxxxxxxxxxxxxxxxx smb-enum-groups xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p445 --script smb-enum-groups --script-args smbusername="$username",smbpassword="$passwd"| tee -a $resfile

    echo -e "${WHITE}------------- trying smb-enum-services with the provided creds -------------${NC}"
    text="xxxxxxxxxxxxxxxxxxxx smb-enum-services xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p445 --script smb-enum-services --script-args smbusername="$username",smbpassword="$passwd"| tee -a $resfile

    echo -e "${WHITE}------------- trying smb-enum-shares,smb-ls with the provided creds -------------${NC}"
    text="xxxxxxxxxxxxxxxxxxxx smb-ls xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p445 --script smb-ls --script-args smbusername="$username",smbpassword="$passwd"| tee -a $resfile

    echo -e "${CYAN}Do you want to use SMBmap? [y/n]${NC}"
    read opp
    if [[ "$opp" == "y" ]]; then
        text="xxxxxxxxxxxxxxxxxxxx SMBMap xxxxxxxxxxxxxxxxxxxx"
        padding=$(( (line_length - ${#text}) / 2 ))
        line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
        echo "$line" | tee -a $resfile
        smbs=$(smbmap -u "$username" -p "$password" -d . -H "$1")
        echo "$smbs" >> $resfile
        if grep -qi " session established" <<< "$smbs"; then
            echo -e "${GREEN}SMB login successful.${NC}"
            echo -e "${MAGENTA}You should try to RCE (-x), list (-L), connect to drive (-r)${NC}"
            echo -e "${MAGENTA}upload (--upload /full/path C$\path\filename) or download (--download /full/path)${NC}"
        else
            echo -e "${RED}No session established${NC}"
        fi
    else
        echo -e "${WHITE}Skipped...${NC}" | tee -a $resfile
    fi
}

smbf() {
    line="SMB ENUM"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"
    printf "%*s\n" $(((${#line}+$line_length)/2)) "$line" >> "$resfile"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"
    text="xxxxxxxxxxxxxxxxxxxx smb-os-discovery xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p445 --script smb-os-discovery | tee -a $resfile

    echo -e "${WHITE}------------- smb-protocols -------------${NC}"
    text="xxxxxxxxxxxxxxxxxxxx smb-protocols xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p445 --script smb-protocols | tee -a $resfile

    echo -e "${WHITE}------------- smb-security-mode -------------${NC}"
    text="xxxxxxxxxxxxxxxxxxxx smb-security-mode xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p445 --script smb-security-mode | tee -a $resfile

    echo -e "${WHITE}------------- smb-enum-sessions -------------${NC}"
    text="xxxxxxxxxxxxxxxxxxxx smb-enum-sessions xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p445 --script smb-enum-sessions | tee -a $resfile

    echo -e "${WHITE}------------- smb-enum-shares -------------${NC}"
    text="xxxxxxxxxxxxxxxxxxxx smb-enum-shares xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p445 --script smb-enum-shares | tee -a $resfile

    echo -e "${CYAN}Do you have valid credentials for SMB? [y/n]${NC}"
    read op
    if [[ "$op" == "y" ]]; then
        echo -e "${CYAN}Please give me the username${NC}"
        read username
        echo -e "${CYAN}Please give me the password${NC}"
        read passwd
        if [[ -z "$username" || -z "$passwd" ]]; then
            echo -e "${RED}Err, inclomplete fields" # maybe that cause an error with an empty pass, and that's possible
        else
            smblogged "$1" "$username" "$passwd"
        fi
    else
        #enum4linux -U "" "$1"

        echo -e "${CYAN}Do you want to try with hydra? (Brute-Force) [y/n]${NC}"
        read b 
        if [[ "$b" == "y" ]]; then
            echo -e "${CYAN}Please give me the full path to userlist${NC}"
            read userlst
            echo -e "${CYAN}Please give me the full path to passwordlist${NC}"
            read passwdlst
            if [[ -z "$userlst" || -z "$passwdlst" ]]; then
                echo -e "${RED}Err, inclomplete fields" # maybe that cause an error with an empty pass, and that's possible
            else
                text="xxxxxxxxxxxxxxxxxxxx HYDRA SMB brute xxxxxxxxxxxxxxxxxxxx"
                padding=$(( (line_length - ${#text}) / 2 ))
                line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
                echo "$line" | tee -a $resfile
                hydr=$(hydra -L "$userlst" -P "$passwdlst" "$1" smb)
                echo "$hydr" >> $resfile
                if grep -qi "[445]" <<< "$nmap_res"; then
                    echo -e "${GREEN}SMB login successful.${NC}"
                    echo "$hydr" | grep -qi "[445]"
                else
                    echo -e "${RED}Credentials not found${NC}"
                fi
            fi
        else
            echo -e "${WHITE}Skipped...${NC}" | tee -a $resfile
        fi
    fi
    echo -e "${GREEN}SMB enumeration done. Check results.txt for more info.${NC}"
}

mysqllogged() {
    text="xxxxxxxxxxxxxxxxxxxx mysql-users xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p445 --script mysql-users --script-args="mysqluser='$username',mysqlpass='$passwd'" | tee -a $resfile

    text="xxxxxxxxxxxxxxxxxxxx mysql-databases xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p445 --script mysql-databases --script-args="mysqluser='$username',mysqlpass='$passwd'" | tee -a $resfile

    text="xxxxxxxxxxxxxxxxxxxx mysql-variables xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p445 --script mysql-variables --script-args="mysqluser='$username',mysqlpass='$passwd'" | tee -a $resfile

    text="xxxxxxxxxxxxxxxxxxxx mysql-audit xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p445 --script mysql-audit --script-args="mysql-audit.username='$username',mysql-audit.password='$passwd',mysql-audit.filename='/usr/share/nmap/nselib/data/mysql-cis.audit'" | tee -a $resfile

    text="xxxxxxxxxxxxxxxxxxxx mysql-dump-hashes xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p445 --script mysql-dump-hashes --script-args="username='$username',password='$passwd'" | tee -a $resfile

    echo -e "${WHITE}------------- trying mysql-query with the provided creds -------------${NC}"
    text="xxxxxxxxxxxxxxxxxxxx mysql-query xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p445 --script mysql-users --script-args="query='SELECT * from information_schema',mysqluser='$username',mysqlpass='$passwd'" | tee -a $resfile
}

mysqlf() {
    line="MYSQL ENUM"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"
    printf "%*s\n" $(((${#line}+$line_length)/2)) "$line" >> "$resfile"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"
    text="xxxxxxxxxxxxxxxxxxxx mysql-empty-password xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p3306 --script mysql-empty-password | tee -a $resfile

    text="xxxxxxxxxxxxxxxxxxxx mysql-info xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p3306 --script mysql-info | tee -a $resfile

    echo -e "${CYAN}Do you have valid credentials for SQL? [y/n]${NC}"
    read op
    if [[ "$op" == "y" ]]; then
        echo -e "${CYAN}Please give me the username${NC}"
        read username
        echo -e "${CYAN}Please give me the password${NC}"
        read passwd
        if [[ -z "$username" || -z "$passwd" ]]; then
            echo -e "${RED}Err, inclomplete fields" # maybe that cause an error with an empty pass, and that's possible
        else
            mysqllogged "$1" "$username" "$passwd"
        fi
    else
        #enum4linux -U "" "$1"

        echo -e "${CYAN}Do you want to try with hydra? (Brute-Force) [y/n]${NC}"
        read b 
        if [[ "$b" == "y" ]]; then
            echo -e "${CYAN}Please give me the full path to userlist${NC}"
            read userlst
            echo -e "${CYAN}Please give me the full path to passwordlist${NC}"
            read passwdlst
            if [[ -z "$userlst" || -z "$passwdlst" ]]; then
                echo -e "${RED}Err, inclomplete fields" # maybe that cause an error with an empty pass, and that's possible
            else
                text="xxxxxxxxxxxxxxxxxxxx HYDRA MySQL brute xxxxxxxxxxxxxxxxxxxx"
                padding=$(( (line_length - ${#text}) / 2 ))
                line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
                echo "$line" | tee -a $resfile
                hydr=$(hydra -L "$userlst" -P "$passwdlst" "$1" mysql)
                echo "$hydr" >> $resfile
                if grep -qi "[445]" <<< "$nmap_res"; then
                    echo -e "${GREEN}MySQL login successful.${NC}"
                    echo "$hydr" | grep -qi "[445]"
                else
                    echo -e "${RED}Credentials not found${NC}"
                fi
            fi
        else
            echo -e "${WHITE}Skipped...${NC}" | tee -a $resfile
        fi
    fi
    echo -e "${GREEN}MySQL enumeration done. Check results.txt for more info.${NC}"
}

ssqlf() {
    line="SSQL ENUM"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"
    printf "%*s\n" $(((${#line}+$line_length)/2)) "$line" >> "$resfile"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"
    echo -e "${WHITE}------------- ms-sql-info -------------${NC}"
    text="xxxxxxxxxxxxxxxxxxxx ms-sql-info xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p1433 --script ms-sql-info | tee -a $resfile

    echo -e "${WHITE}------------- ms-sql-ntlm-info -------------${NC}"
    text="xxxxxxxxxxxxxxxxxxxx ms-sql-ntlm-info xxxxxxxxxxxxxxxxxxxx"
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line" | tee -a $resfile
    nmap "$1" -p1433 --script ms-sql-ntlm-info --script-args mssql.instance-port=1433 | tee -a $resfile

    echo -e "${CYAN}Do you have valid credentials for SSQL? [y/n]${NC}"
    read op
    if [[ "$op" == "y" ]]; then
        echo -e "${CYAN}Please give me the username${NC}"
        read username
        echo -e "${CYAN}Please give me the password${NC}"
        read passwd
        if [[ -z "$username" || -z "$passwd" ]]; then
            echo -e "${RED}Err, inclomplete fields" # maybe that cause an error with an empty pass, and that's possible
        else
            mysqllogged "$1" "$username" "$passwd"
        fi
    else
        #enum4linux -U "" "$1"
        text="xxxxxxxxxxxxxxxxxxxx ms-sql-empty-password xxxxxxxxxxxxxxxxxxxx"
        padding=$(( (line_length - ${#text}) / 2 ))
        line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
        echo "$line" | tee -a $resfile
        nmap "$1" -p1433 --script ms-sql-empty-password

        echo -e "${CYAN}Do you want to try with ms-sql-brute? (Brute-Force) [y/n]${NC}"
        read b 
        if [[ "$b" == "y" ]]; then
            echo -e "${CYAN}Please give me the full path to userlist${NC}"
            read userlst
            echo -e "${CYAN}Please give me the full path to passwordlist${NC}"
            read passwdlst
            if [[ -z "$userlst" || -z "$passwdlst" ]]; then
                echo -e "${RED}Err, inclomplete fields" # maybe that cause an error with an empty pass, and that's possible
            else
                text="xxxxxxxxxxxxxxxxxxxx ms-sql-brute xxxxxxxxxxxxxxxxxxxx"
                padding=$(( (line_length - ${#text}) / 2 ))
                line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
                echo "$line" | tee -a $resfile
                hydr=$(nmap "$1" -p1433 --script ms-sql-brute --script-args userdb="$usrlst",passdb="$passwdlst")
                echo "$hydr" >> $resfile
                if grep -qi "Login Success" <<< "$nmap_res"; then
                    echo -e "${GREEN}SSQL login successful.${NC}"
                    echo "$hydr" | grep -qi "Login Success"
                else
                    echo -e "${RED}Credentials not found${NC}"
                fi
            fi
        else
            echo -e "${WHITE}Skipped...${NC}" | tee -a $resfile
        fi
    fi
    echo -e "${GREEN}SSQL enumeration done. Check results.txt for more info.${NC}"
}

if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
    echo -e "${RED}Usage: ./autoEnum.sh <IP> <tcp/udp> <port>${NC}"
    exit 1
else
    if [[ "$2" == "tcp" ]]; then
        case "$3" in
            21)
                ftpf "$1"
                ;;
            22)
                sshf "$1"
                ;;
            80)
                httpf "$1"
                ;;
            445)
                 smbf "$1"
                ;;
            3306)
                mysqlf "$1"
                ;;
            1433)
                ssqlf "$1"
                ;;
            *)
                echo -e "${RED}I'm not available yet to enumerate that port. You should do it manually.${NC}"
                exit 1
                ;;
        esac
    elif [[ "$2" == "udp" ]]; then
        echo -e "${RED}UDP port enumeration is under development.${NC}"
        exit 1
    else
        echo -e "${RED}I don't know that protocol.${NC}"
        exit 1
    fi
fi