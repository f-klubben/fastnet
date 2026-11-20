#!/bin/sh
# Genindlæser dialplan og SIP-endpoints. Kør på Pi'en.
set -e

sudo asterisk -rx 'dialplan reload'
sudo asterisk -rx 'pjsip reload'
