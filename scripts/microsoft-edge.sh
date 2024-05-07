#!/usr/bin/env bash
set -ouex pipefail

echo "Installing Microsoft Edge"

mv /var/opt/microsoft /usr/lib/microsoft

rm /etc/cron.daily/microsoft-edge -f 

cat >/usr/lib/tmpfiles.d/msedge.conf <<EOF
L  /opt/microsoft  -  -  -  -  /usr/lib/microsoft
L  /usr/bin/microsoft-edge-stable  -  -  -  -  /usr/lib/microsoft/msedge/microsoft-edge
EOF