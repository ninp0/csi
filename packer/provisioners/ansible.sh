#!/bin/bash --login
source /etc/profile.d/globals.sh

$screen_cmd "${apt} install -y ansible"
grok_error
