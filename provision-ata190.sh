#!/bin/sh
# Provisionerer ATA190-modemmet (port 1). Kør på Pi'en: sudo ./provision-ata190.sh [ata-ip]
set -e

REPO=$(cd "$(dirname "$0")" && pwd)
ATA=${1:-192.168.2.67}
TFTP_IP=192.168.2.1
LOGIN=498836900e3cb4d343b96f3f1c578f4a

login() {
	curl -s -m3 -o /dev/null -d "submit_button=login&keep_name=1&enc=1&user=admin&pwd=$LOGIN" "http://$ATA/login.cgi"
}

registered() {
	login
	curl -s -m3 -u admin:admin "http://$ATA/admin/voice/" |
		grep -o -m1 'Registration State:.*' |
		sed 's/.*darkblue">\([^<]*\)<.*/\1/' | grep -qx 'Registered'
}

sudo python3 "$REPO/ata190/tftpd.py" "$REPO/ata190" &
TFTP_PID=$!
trap 'sudo kill "$TFTP_PID" 2>/dev/null || true' EXIT
sleep 1

login || true
curl -s -o /dev/null -u admin:admin -d "23279=$TFTP_IP" "http://$ATA/admin/voice/acisco.spa" || true
curl -s -o /dev/null -u admin:admin "http://$ATA/admin/reboot" || true

i=0
while [ "$i" -lt 40 ] && curl -s -m2 -o /dev/null "http://$ATA/"; do
	i=$((i + 1))
	sleep 2
done

i=0
while [ "$i" -lt 60 ]; do
	if registered; then
		echo "ATA190 registreret som 190"
		exit 0
	fi
	i=$((i + 1))
	sleep 3
done

echo "ATA190 registrerede ikke" >&2
exit 1
