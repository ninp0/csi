#!/bin/bash
source /etc/profile.d/globals.sh
$screen_cmd "cd /opt && git clone https://github.com/danielmiessler/SecLists SecLists-dev ${assess_update_errors}"
grok_error
