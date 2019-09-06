#!/bin/bash --login
# Automate Package Install Questions :)
# Obtain values via: debconf-get-selections | less

csi_provider=`echo $CSI_PROVIDER`

# Update OS per update_os_instructions function and grok for errors in screen session logs
# to mitigate introduction of bugs during updgrades.
screen_cmd='sudo screen -L -S update_os -d -m /bin/bash --login -c'
assess_update_errors='|| echo UPDATE_ABORT && exit 1'
debconf_set='/usr/bin/debconf-set-selections'
apt="DEBIAN_FRONTEND=noninteractive apt -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold'"

grok_error() {
  while true; do
    # Wait until screen exits session
    sudo screen -ls | grep update_os
    if [[ $? == 1 ]]; then
      grep UPDATE_ABORT screenlog.*
      if [[ $? == 0 ]]; then
        echo 'Failures encountered in screenlog for update_os session!!!'
        cat screenlog.*
        exit 1
      else
        echo 'No errors in update detected...moving onto the next.'
        break 
      fi
    else
      printf '.'
      sleep 9
    fi
  done
}

# PINNED PACKAGES
# pin openssl for arachni proxy plugin Arachni/arachni#1011
sudo /bin/bash --login -c 'echo "Package: openssl" > /etc/apt/preferences.d/openssl'
sudo /bin/bash --login -c 'echo "Pin: version 1.1.0*" >> /etc/apt/preferences.d/openssl'
sudo /bin/bash --login -c 'echo "Pin-Priority: 1001" >> /etc/apt/preferences.d/openssl'

# pin until breadcrumbs are implemented in the framwework
sudo /bin/bash --login -c 'echo "Package: jenkins" > /etc/apt/preferences.d/jenkins'
sudo /bin/bash --login -c 'echo "Pin: version 2.190" >> /etc/apt/preferences.d/jenkins'
sudo /bin/bash --login -c 'echo "Pin-Priority: 1002" >> /etc/apt/preferences.d/jenkins'

# Cleanup up prior screenlog.0 file from previous update_os failure(s)
if [[ -e screenlog.0 ]]; then 
  sudo rm screenlog.*
fi

$screen_cmd "apt update ${assess_update_errors}"
grok_error

$screen_cmd "apt install -yq debconf-i18n ${assess_update_errors}"
grok_error

$screen_cmd "echo 'samba-common samba-common/dhcp boolean false' | ${debconf_set} ${assess_update_errors}"
grok_error

$screen_cmd "echo 'libc6 libraries/restart-without-asking boolean true' | ${debconf_set} ${assess_update_errors}"
grok_error

$screen_cmd "echo 'console-setup console-setup/codeset47 select Guess optimal character set' | ${debconf_set} ${assess_update_errors}"
grok_error

$screen_cmd "echo 'wireshark-common wireshark-common/install-setuid boolean false' | ${debconf_set} ${assess_update_errors}"
grok_error

$screen_cmd "${apt} dist-upgrade -yq ${assess_update_errors}"
grok_error

$screen_cmd "${apt} full-upgrade -yq ${assess_update_errors}"
grok_error

grep kali /etc/apt/sources.list
if [[ $? == 0 ]]; then
   $screen_cmd "${apt} install -yq kali-linux ${assess_update_errors}"
   grok_error

   $screen_cmd "${apt} install -yq kali-linux-full ${assess_update_errors}"
   grok_error

   $screen_cmd "${apt} install -yq kali-desktop-gnome ${assess_update_errors}"
   grok_error
else
  echo "Other Linux Distro Detected - Skipping kali-linux-full Installation..."
fi

$screen_cmd "${apt} install -yq apt-file ${assess_update_errors}"
grok_error

$screen_cmd "apt-file update ${assess_update_errors}"
grok_error

$screen_cmd "${apt} autoremove -yq --purge ${assess_update_errors}"
grok_error

$screen_cmd "${apt} -yq clean"
grok_error

$screen_cmd "dpkg --configure -a ${assess_update_errors}"
grok_error

printf 'OS updated to reasonable expectations - cleaning up screen logs...'
sudo rm screenlog.*
echo 'complete.'
