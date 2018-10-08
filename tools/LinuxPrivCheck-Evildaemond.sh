# Updated LinuxPrivCheck by Evildaemond                                           #
# Updated with the following                                                      #
# * Checking for .htaccess and .htpasswd                                          #
# * Check for sudo permissions for commands                                       #
# * Filtering Common SUID files                                                   #
# * Check Bash Version                                                            #

echo    "                                          "
echo -e "\e[35m#----------------------------------#"
echo -e "\e[35m#          \e[36m OS Information  \e[35m       #"
echo -e "\e[35m#----------------------------------#"
echo    "                                          "
echo -e "\e[39m"
uname -a                                                                                                # Kernel Version
cat /etc/issue                                                                                          # Distribution
cat /etc/*release                                                                                       # OS Release
echo    "                                          "
echo -e "\e[35m#----------------------------------#"
echo -e "\e[35m#        \e[36m Network Information  \e[35m    #"
echo -e "\e[35m#----------------------------------#"
echo    "                                          "
echo -e "\e[39m"
cat /etc/resolv.conf                                                                                    # Nameservers
cat /etc/hosts                                                                                          # Hosts
route -n                                                                                                # Route Info.
iptables -L                                                                                             # Firewall Rules
cat /etc/network/interfaces                                                                             # Network Interfaces
echo    "                                          "
echo -e "\e[35m#----------------------------------#"
echo -e "\e[35m#       \e[36m Password Information     \e[35m #"
echo -e "\e[35m#----------------------------------#"
echo    "                                          "
echo -e "\e[39m"
echo -e "\e[34m"
echo "----------|Password File|-----------"
echo "                                    "
echo -e "\e[39m"
cat /etc/passwd  
echo "                                    "                                                              # Password File
echo -e "\e[39m"
echo -e "\e[34m"
echo "-----------|Shadow File|------------"
echo "                                    "
echo -e "\e[39m"
cat /etc/shadow                                                                                          # Shadow File
echo "                                    "
echo -e "\e[34m"
echo "                                    "
echo "------------|SSH Keys|--------------"
echo "                                    "
echo -e "\e[39m"
cat /root/.ssh/authorized_keys                                                                           # Authorized SSH Keys
cat /root/.ssh/known_hosts                                                                               # SSH Known Hosts
cat ~/.ssh/id_rsa                                                                                        # RSA Keys
cat ~/.ssh/id_dsa                                                                                        # DSA Keys
cat /etc/ssh/ssh_host_dsa_key                                                                            # Alernative DSA keys
cat /etc/ssh/ssh_host_rsa_key                                                                            # Alternative RSA Keys
echo    "                                          "
echo -e "\e[35m#----------------------------------#"
echo -e "\e[35m#         \e[36m Misc. Information  \e[35m     #"
echo -e "\e[35m#----------------------------------#"
echo    "                                          "
echo -e "\e[39m"
echo -e "\e[34m"
echo "------|Important Executables|-------"
echo -e "\e[39m"
echo "                                    "
which wget                                                                                               # Check Wget
which nc                                                                                                 # Check Nc
which netcat                                                                                             # Check Netcat
which python                                                                                             # Check Python
which python3                                                                                            # Check Python3
which gcc                                                                                                # Check GCC
which perl                                                                                               # Check Perl
echo    "                                          "
echo -e "\e[39m"
echo -e "\e[34m"
echo "------|Enviroment Information|-------"
echo -e "\e[39m"
echo "                                    "
/bin/bash --version | grep version -m 1                                                                 # Bash Enviroment Details
echo "                                    "
echo -e "\e[34m"
echo "                                    "
echo "-----------|Sudoers File|-----------"
echo "                                    "
echo -e "\e[39m"
cat /etc/sudoers                                                                                         # Check Sudoers
/usr/bin/sudo -l                                                                                         # Check Sudo commands
# May remove due to password requirement
echo -e "\e[34m"
echo "                                    "
echo "--------------|Users|---------------"
echo "                                    "
echo -e "\e[39m"
cat /etc/passwd | cut -d: -f1                                                                            # List Users
echo -e "\e[34m"
echo "                                    "
echo "-------------|Groups|---------------"
echo "                                    "
echo -e "\e[39m"
cat /etc/group                                                                                           # Check Groups
echo -e "\e[34m"
echo "                                    "
echo "-----------|SUID Files|-------------"
echo "                                    "
echo -e "\e[39m"
find / \( -perm -4000 \) -exec ls -ld {} \; 2>/dev/null | awk '{print $9}' > SUID_FILES.txt              # Check SUID Files 
    sleep 2

for bname in '/umount/d' '/su/d' '/mount/d' '/sudo/d' '/passwd/d' '/exim4/d' '/chfn/d' '/chsh/d' '/procmail/d' '/newgrp/d' '/ping/d' '/ntfs-3g/d' '/pppd/d' '/pkexec/d' '/ssh-keysign/d' '/dbus-daemon-launch-helper/d' '/uuidd/d' '/pt_chown/d' '/at/d' '/mtr/d' '/dmcrypt-get-device/d' '/X/d' '/traceroute6.iputils/d' '/polkit-resolve-exe-helper/d' '/polkit-set-default-helper/d' '/polkit-grant-helper-pam/d'

do
  sed -i $bname ./SUID_FILES.txt
done
sleep 2

for line in $(cat SUID_FILES.txt); do                              
echo $line
done
echo -e "\e[34m"
echo "                                    "
echo "-----------|GUID Files|-------------"
echo "                                    "
echo -e "\e[39m"
find / -type f -perm -g=s -exec ls -la {} + 2>/dev/null | awk '{print $9}'                               # Check GUID Files 
echo -e "\e[34m"
echo "                                    "
echo "-----------|NO ROOT SQUASH|---------"
echo "                                    "
echo -e "\e[39m"                                                                                         # check no_root_squash
if [ $(cat /etc/exports 2>/dev/null | grep no_root_squash | wc -c) -ne 0 ]
then
  echo "NO_ROOT_SQUASH FOUND! " && cat /etc/exports | grep no_root_squash
else
  echo "NO_ROOT_SQUASH NOT FOUND!"
fi
echo -e "\e[34m"
echo "                                    "
echo "----------------|EXIM|--------------"
echo "                                    "
echo -e "\e[39m"                                                                                         # Check exim              
if [ $(which exim | wc -c) -ne 0 ]
then
  echo -n "EXIM FOUND! " && exim -bV | grep version
else
  echo "EXIM NOT FOUND!"
fi
echo -e "\e[34m"
echo "                                    "
echo "-------------|CHKROOTKIT|-----------"
echo "                                    "
echo -e "\e[39m"                                                                                         # Check chkrootkit              
if [ $(which chkrootkit | wc -c) -ne 0 ]
then
  echo -n "CHKROOTKIT FOUND! " && chkrootkit -V
else
  echo "CHKROOTKIT NOT FOUND!"
fi
echo -e "\e[34m"
echo "                                    "
echo "-------------|MySQL Creds|-----------"
echo "                                    "
echo -e "\e[39m"                                                                                         # Check MySQL Creds              
if [ $(find / -iname wp-config.php 2>/dev/null | wc -c) -ne 0 ]
then
  echo "WP-CONFIG.PHP FOUND! " && cat $(locate wp-config.php) | grep DB_NAME && cat $(locate wp-config.php) | grep DB_USER && cat $(locate wp-config.php) | grep DB_PASSWORD 
else
  echo "WP-CONFIG.PHP NOT FOUND!"
fi
echo -e "\e[34m"
echo "                                    "
echo "------------|HTTP Creds|------------"
echo "                                    "
echo -e "\e[39m"
if [ $(find / -iname .htpasswd 2>/dev/null | wc -c) -ne 0 ]                                              # Check .htpasswd creds
then 
  echo ".HTPASSWD FOUND!" && cat $(locate .htpasswd)
else
  echo ".HTPASSWD NOT FOUND!"
fi
echo -e "\e[34m"
echo "                                    "
echo "--------------|FSTab|---------------"
echo "                                    "
echo -e "\e[39m"
cat /etc/fstab                                                                                           # Check Fstab
echo -e "\e[34m"
echo "                                    "
echo "---------|Daily Cron Jobs|----------"
echo "                                    "
echo -e "\e[39m"
ls -la /etc/cron.d/                                                                                      # Check Cron Jobs
ls -la /etc/cron.daily/                                                                                  # Alternative Check Cron Jobs
echo -e "\e[34m"
echo "                                    "
echo "-------------|Crontab|--------------"
echo "                                    "
echo -e "\e[39m"
cat /etc/crontab                                                                                         # Check Crontab
echo -e "\e[34m"
echo "                                    "
echo "------|World Writable Folders|------"
echo "                                    "
echo -e "\e[39m"
find / -perm -222 -type d 2>/dev/null                                                                     # World Wireable Folders
echo -e "\e[34m"
echo "                                    "
echo "-----------|Home Directory|---------"
echo "                                    "
echo -e "\e[39m"
ls -ahlR /home 2>/dev/null | sed -n '4,$p'                                                                # Check Home Directory
echo "                                    "
echo -e "\e[34m"
echo "                                    "
echo "------------|Bash History|----------"
echo "                                    "
echo -e "\e[39m"
for homedirs in $(ls -ahl /home 2>/dev/null | sed -n '4,$p' | awk '{print $9}')                           # Check Bash History
do
  cat /home/$homedirs/.bash_history
done
touch ~/.bash_history                                                                                     # Clear Command History
echo    "                                          "
echo -e "\e[35m#----------------------------------#"
echo -e "\e[35m#   \e[36m Script has been completed!  \e[35m  #"
echo -e "\e[35m#----------------------------------#"
echo    "                                          "
echo -e "\e[39m"