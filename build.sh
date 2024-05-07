#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

rpm --import https://packages.microsoft.com/keys/microsoft.asc
rpm --import https://repository.mullvad.net/rpm/mullvad-keyring.asc

get_yaml_array() {
  local -n arr=$1
  local jq_query=$2
  local module_config=$3

  if [[ -z $jq_query || -z $module_config ]]; then
    echo "Usage: get_yaml_array VARIABLE_TO_STORE_RESULTS JQ_QUERY MODULE_CONFIG" >&2
    return 1
  fi

  readarray -t arr < <(echo "$module_config" | yq -I=0 "$jq_query" "$3")
}

export -f get_yaml_array


# Install yq to process yaml
curl -Lo /tmp/yq.tar.gz "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64.tar.gz"
tar -xzf /tmp/yq.tar.gz -C /tmp
mv /tmp/yq_linux_amd64 /tmp/yq
install -c -m 0755 /tmp/yq /usr/bin

rpm-ostree install yq
rpm-ostree install wget
### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1
bash /tmp/1password.sh
bash /tmp/rpm-ostree.sh /tmp/apps.yml
bash /tmp/scripts/mullvad-vpn.sh
bash /tmp/scripts/microsoft-edge.sh
rpm-ostree uninstall yq

# this installs a package from fedora repos


# this would install a package from rpmfusion
# rpm-ostree install vlc


#### Example for enabling a System Unit File

systemctl enable podman.socket
#systemctl enable mullvad-daemon
#systemctl enable mullvad-early-boot-blocking

# Clean up the yum repo (updates are baked into new images)
rm /etc/yum.repos.d/mullvad.repo -f
rm /etc/yum.repos.d/microsoft-edge.repo -f
rm /etc/yum.repos.d/vscode.repo -f
