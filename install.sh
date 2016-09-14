#!/bin/bash


printf "Enter the IP of the IPA Server: "
read ipa_ip

printf "Enter the Hostname of the IPA Server: "
read ipa_hostname

printf "Enter the Domain Name of the IPA Server: "
read ipa_domain

echo "$ipa_ip    $ipa_hostname.$ipa_domain $ipa_hostname"


sudo -E apt-add-repository http://ppa.launchpad.net/freeipa/ppa/ubuntu
sudo -E apt-add-repository http://ppa.launchpad.net/sssd/updates/ubuntu
sudo apt-get update
sudo apt-get upgrade

echo 
echo "$ipa_ip    $ipa_hostname.$ipa_domain $ipa_hostname" | sudo tee -a /etc/hosts

sudo apt-get install openssh-server freeipa-client sssd

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


sudo ipa-client-install -N --hostname $ipa_hostname.$ipa_domain --mkhomedir
sudo sed -i 's/_srv_,\s+/ /' /etc/sssd/sssd.conf

sudo service sssd restart


sudo cp -pv 50-myconfig.conf /usr/share/lightdm/lightdm.conf.d/50-myconfig.conf
sudo service lightdm restart
