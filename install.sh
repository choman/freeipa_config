#!/bin/bash


default="/usr/bin/apt-get"
app_cmd=$(which apt-fast)

if [ -z "$app_cmd" ]; then
   app_cmd="/usr/bin/apt-get"
fi

apt_cmd=${tmp-$default}

printf "Enter the IPA Server IP: "
read ipa_ip

printf "Enter the IPA Server Hostname: "
read ipa_hostname

printf "Enter the IPA Server Domain: "
read ipa_domain

echo "$ipa_ip    $ipa_hostname.$ipa_domain $ipa_hostname"


sudo -E apt-add-repository http://ppa.launchpad.net/freeipa/ppa/ubuntu
sudo -E apt-add-repository http://ppa.launchpad.net/sssd/updates/ubuntu
sudo $app_cmd update
sudo $app_cmd dist-upgrade -y

echo 
echo "$ipa_ip    $ipa_hostname.$ipa_domain $ipa_hostname" | sudo tee -a /etc/hosts

sudo $app_cmd install -y openssh-server freeipa-client sssd

sudo rm /etc/ipa/default.conf

sudo mkdir /var/run/ipa
sudo mkdir -p /etc/pki/nssdb

ntpq -pn

sudo bash -c "cat > /usr/share/pam-configs/mkhomedir" <<EOF
Name: activate mkhomedir
Default: yes
Priority: 900
Session-Type: Additional
Session:
        required                        pam_mkhomedir.so umask=0022 skel=/etc/skel
EOF

sudo pam-auth-update


sudo ipa-client-install -N --domain $ipa_domain --server $ipa_hostname.$ipa_domain --mkhomedir
sudo sed -i 's/_srv_,\s+/ /' /etc/sssd/sssd.conf

sudo service sssd restart


sudo cp -pv 50-myconfig.conf /usr/share/lightdm/lightdm.conf.d/50-myconfig.conf
sudo service lightdm restart
