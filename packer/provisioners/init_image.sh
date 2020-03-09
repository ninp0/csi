#!/bin/bash --login
source /etc/profile.d/globals.sh

csi_env_file='/etc/profile.d/csi_envs.sh'
csi_provider=`echo $CSI_PROVIDER`

if [[ $csi_provider == 'docker' ]]; then
  apt update && apt install -y sudo screen
  echo 'Set disable_coredump false' >> /etc/sudoers
else
  sudo apt update && sudo apt install -y screen
fi

sudo tee -a $csi_env_file << EOF
export CSI_ROOT='/opt/csi'
export CSI_PROVIDER='${csi_provider}'
EOF

$screen_cmd "chmod 755 ${csi_env_file} ${assess_update_errors}"
grok_error

case $csi_provider in
  'aws')
    # Begin Converting to Kali Rolling
    $screen_cmd "${apt} install -y gnupg2 dirmngr software-properties-common ${assess_update_errors}"
    grok_error

    $screen_cmd "rm -rf /var/lib/apt/lists && > /etc/apt/sources.list && add-apt-repository 'deb https://http.kali.org/kali kali-rolling main non-free contrib' && echo 'deb-src https://http.kali.org/kali kali-rolling main contrib non-free' >> /etc/apt/sources.list && apt-key adv --keyserver hkp://keys.gnupg.net --recv-keys 7D8D0BF6 ${assess_update_errors}"
    grok_error

    # Download and import the official Kali Linux key
    $screen_cmd "wget -q -O - https://archive.kali.org/archive-key.asc | sudo apt-key add ${assess_update_errors}"
    grok_error

    # Update our apt db so we can install kali-keyring
    $screen_cmd "apt update ${assess_update_errors}"
    grok_error

    # Install the Kali keyring
    $screen_cmd "${apt} install -y kali-archive-keyring ${assess_update_errors}"
    grok_error

    # Update our apt db again now that kali-keyring is installed
    $screen_cmd "apt update ${assess_update_errors}"
    grok_error

    $screen_cmd "${apt} install -y kali-linux ${assess_update_errors}"
    grok_error

    $screen_cmd "${apt} install -y kali-linux-full ${assess_update_errors}"
    grok_error

    $screen_cmd "${apt} install -y kali-desktop-xfce ${assess_update_errors}"
    grok_error

    $screen_cmd "dpkg --configure -a ${assess_update_errors}"
    grok_error

    $screen_cmd "${apt} -y autoremove --purge ${assess_update_errors}"
    grok_error

    $screen_cmd "${apt} -y clean"
    grok_error
    ;;

  'docker')
    $screen_cmd "${apt} install -y curl gnupg2 openssh-server net-tools"
    grok_error

    $screen_cmd "service ssh start"
    grok_error

    $screen_cmd "${apt} dist-upgrade -y ${assess_update_errors}"
    grok_error

    $screen_cmd "${apt} full-upgrade -y ${assess_update_errors}"
    grok_error

    $screen_cmd "useradd -m -s /bin/bash admin ${assess_update_errors}"
    grok_error

    $screen_cmd "usermod -aG sudo admin ${assess_update_errors}"
    grok_error
    ;; 
  'qemu') 
    $screen_cmd "useradd -m -s /bin/bash admin ${assess_update_errors}"
    grok_error

    $screen_cmd "usermod -aG sudo admin ${assess_update_errors}"
    grok_error
    ;;

  'virtualbox') 
    $screen_cmd "useradd -m -s /bin/bash admin ${assess_update_errors}"
    grok_error

    $screen_cmd "usermod -aG sudo admin ${assess_update_errors}"
    grok_error
    ;;

  'vmware') 
    $screen_cmd "useradd -m -s /bin/bash admin ${assess_update_errors}"
    grok_error

   $screen_cmd "usermod -aG sudo admin ${assess_update_errors}"
   grok_error
   ;;

  *) echo "ERROR: Unknown CSI Provider: ${csi_provider}"
     exit 1
     ;;
esac

# Restrict Home Directory
sudo chmod 700 /home/admin
