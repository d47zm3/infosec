#!/bin/bash

# script to set up kali with basic services and useful tools

function decho
{
        string=$1
        echo "[$( date +'%H:%M:%S' )] ${string}"
}

decho "Update system..."
apt-get update
apt-get dist-upgrade

decho "Enable servces..."
service postgresql start
service ssh start
systemctl enable postgresql
systemctl enable ssh
msfdb reinit

decho "Installing utilities..."
decho "Install discover scripts..."
cd /opt
git clone https://github.com/leebaird/discover
cd discover
./setup.sh
decho "Installing smbexec..."
cd /opt
git clone https://github.com/brav0hax/smbexec.git
cd smbexec
decho "Choose option 1... Install to /opt"
./install.sh
decho "Choose option 4..."
./install.sh
cd /opt
decho "Install Veil..."
cd /opt/
git clone https://github.com/veil-evasion/Veil.git
cd ./Veil/setup
./setup.sh
decho "Install WCE - Windows Credential Editor"
cd ~/Desktop
wget http://www.ampliasecurity.com/research/wce_v1_41beta_universal.zip
unzip -d ./wce wce_v1_41beta_universal.zip
decho "Install Mimikatz..."
cd ~/Desktop
wget http://blog.gentilkiwi.com/downloads/mimikatz_trunk.zip
unzip -d./mimikatz mimikatz_trunk.zip
decho "Install PeepingTom..."
cd/opt/
git clone https://bitbucket.org/LaNMaSteR53/peepingtom.git
cd ./peepingtom/
wget https://gist.github.com/nopslider/5984316/raw/423b02c53d225fe8dfb4e2df9a20bc800cc
wget https://phantomjs.googlecode.com/files/phantomjs1.9.2-linux-i686.tar.bz2
tar xvjf phantomjs-1.9.2-linux-i686.tar.bz2
cp ./phantomjs-1.9.2-linux-i686/bin/phantomjs .
decho "Install nmap banner script..."
cd/usr/share/nmap/scripts/
wget https://raw.github.com/hdm/scan-tools/master/nse/banner-plus.nse
decho "Install PowerSploit..."
cd /opt/
git clone https://github.com/mattifestation/PowerSploit.git
cd PowerSploit
wget https://raw.github.com/obscuresec/random/master/StartListener.py
wget https://raw.github.com/darkoperator/powershell_scripts/master/ps_encoder.py
decho "Install Responder..."
cd /opt/
git clone https://github.com/SpiderLabs/Responder.git
decho "Install Bypass UAC..."
cd /opt/
wget http://www.secmaniac.com/files/bypassuac.zip
unzip bypassuac.zip
cp bypassuac/bypassuac.rb /opt/metasploit/apps/pro/msf3/scripts/meterpreter/
mv bypassuac/uac/ /opt/metasploit/apps/pro/msf3/data/exploits/
decho "Install BeEF"
apt-get install beef-xss
decho "Install Fuzzing Lists..."
cd /opt/
git clone https://github.com/danielmiessler/SecLists.git
