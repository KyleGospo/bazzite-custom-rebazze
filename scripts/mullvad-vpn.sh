#!/usr/bin/env bash
set -ouex pipefail

echo "Installing Mullvad VPN"

PACKAGE_NAME="MullvadVPN"
PACKAGE_OPT_NAME="Mullvad VPN"
UNPACK_PATH="/tmp/${PACKAGE_NAME}"
OPT_PATH="/usr/lib/${PACKAGE_OPT_NAME}"
curl -Lo /tmp/mv.rpm https://mullvad.net/en/download/app/rpm/latest

mkdir -p /var/opt

_DIR=$(pwd)

mkdir -p $UNPACK_PATH
cd $UNPACK_PATH

rpm2cpio /tmp/mv.rpm | cpio -idmv

mv "${UNPACK_PATH}/opt/${PACKAGE_OPT_NAME}" "/usr/lib"
cp -rv "${UNPACK_PATH}/usr" "/"

ln -s "${OPT_PATH}/mullvad-vpn" /usr/bin
ln -s "${OPT_PATH}/mullvad-gui" /usr/bin

# Register path symlink
# We do this via tmpfiles.d so that it is created by the live system.
cat >/usr/lib/tmpfiles.d/mullvad.conf <<EOF
L  /opt/Mullvad\x20VPN  -  -  -  -  /usr/lib/Mullvad\x20VPN
EOF

## restore path
cd $_DIR
