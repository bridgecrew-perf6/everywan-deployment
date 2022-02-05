#!/bin/bash

# Software versions
EVERYWAN_PROTO_VERSION=v0.1.0
EVERYWAN_STAMP_LIBRARY_VERSION=v0.1.1
EVERYWAN_DATA_PLANE_VERSION=v0.1.0
EVERYWAN_AUTHENTICATION_LIBRARY_VERSION=v0.1.0

if [ "$EUID" -ne 0 ]
  then echo "This script must run as root."
  exit
fi

usage() {
	echo "Usage: $0 [-c <controller-ip>] [-p <controller-port>] [-d <deployment-dir>]" 1>&2
  exit 1
}

while getopts ":c:p:d:" opt
do
    case $opt in
        c) CONTROLLER_IP="${OPTARG}" ;;
        p) CONTROLLER_PORT="${OPTARG}" ;;
        d) DEPLOYMENT_DIR="${OPTARG}" ;;
        *) usage ;;
    esac
done

if [ -z "$CONTROLLER_IP" ]
then
   CONTROLLER_IP="127.0.0.1"
fi

if [ -z "$CONTROLLER_PORT" ]
then
   CONTROLLER_PORT="50061"
fi

if [ -z "$DEPLOYMENT_DIR" ]
then
   DEPLOYMENT_DIR="/opt"
fi

# Paths
CONFIG_FOLDER="/etc/everyedge"
CONFIG_FILENAME="${CONFIG_FOLDER}/config.ini"
DEVICE_INFO_FILENAME="${CONFIG_FOLDER}/device-info.json"
EVERYEDGE_FOLDER="${DEPLOYMENT_DIR}/everyedge"
VENV_FOLDER="${EVERYEDGE_FOLDER}/everyedge-venv"
VENV_ACTIVATE_SCRIPT="${VENV_FOLDER}/bin/activate"
STARTER_FILENAME="${EVERYEDGE_FOLDER}/starter.sh"
REPOS_FOLDER="/tmp/everywan-repos"

# Remove previous versions of EveryEdge
rm -rf ${EVERYEDGE_FOLDER}
rm -rf ${REPOS_FOLDER}

# Create EveryEdge folder
mkdir -p ${EVERYEDGE_FOLDER}

# Update the package lists
apt-get update || { echo 'Failed' ; exit 1; }

# Install dependencies
DEBIAN_FRONTEND="noninteractive" apt-get install -y git python3 python3-pip jq libffi-dev libssl-dev || { echo 'Failed' ; exit 1; }

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Reload .bashrc
source ~/.bashrc

# Create a virtual environment
python3 -m venv "${VENV_FOLDER}" || { echo 'Failed' ; exit 1; }

# Activate the virtual environment
source "${VENV_ACTIVATE_SCRIPT}" || { echo 'Failed' ; exit 1; }

# Workaround to solve an issue related to protobuf versions
# We force the installationof protobuf 3.19.1
pip3 install protobuf==3.19.1 || { echo 'Failed' ; exit 1; }

# Download public key for github.com
mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts || { echo 'Failed' ; exit 1; }

# Download public key for bitbucket.org
mkdir -p -m 0600 ~/.ssh && ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts || { echo 'Failed' ; exit 1; }

# Create a temporary folder to download repositories
mkdir -p ${REPOS_FOLDER} || { echo 'Failed' ; exit 1; }

# Clone the repositories
git clone git@github.com:cscarpitta/pynat.git ${REPOS_FOLDER}/pynat || { echo 'Failed' ; exit 1; }
git clone git@github.com:everywan-io/srv6-sdn-data-plane.git --branch $EVERYWAN_DATA_PLANE_VERSION  ${REPOS_FOLDER}/srv6-sdn-data-plane || { echo 'Failed' ; exit 1; }
git clone git@github.com:everywan-io/srv6-sdn-proto.git --branch $EVERYWAN_PROTO_VERSION  ${REPOS_FOLDER}/srv6-sdn-proto || { echo 'Failed' ; exit 1; }
git clone git@github.com:everywan-io/srv6-sdn-authentication.git --branch $EVERYWAN_AUTHENTICATION_LIBRARY_VERSION  ${REPOS_FOLDER}/srv6-sdn-authentication || { echo 'Failed' ; exit 1; }
git clone git@github.com:cscarpitta/srv6pm-delay-measurement.git --branch $EVERYWAN_STAMP_LIBRARY_VERSION  ${REPOS_FOLDER}/srv6pm-delay-measurement || { echo 'Failed' ; exit 1; }

# Workaround: The patch which introduces the support for End.DT4 and End.DT46
# behaviors has not been accepted yet
# We fix this issue by using our patched version of pyroute2
pip3 install twine
git clone https://github.com/cscarpitta/pyroute2.git --branch srv6_end_dt4 ${REPOS_FOLDER}/pyroute2 || { echo 'Failed' ; exit 1; }
cd ${REPOS_FOLDER}/pyroute2 || { echo 'Failed' ; exit 1; }
make dist python=python3 || { echo 'Failed' ; exit 1; }
pip3 install dist/pyroute2.core-* || { echo 'Failed' ; exit 1; }
pip3 install dist/pyroute2.ethtool-* || { echo 'Failed' ; exit 1; }
pip3 install dist/pyroute2.ipdb-* || { echo 'Failed' ; exit 1; }
pip3 install dist/pyroute2.ipset-* || { echo 'Failed' ; exit 1; }
pip3 install dist/pyroute2.minimal-* || { echo 'Failed' ; exit 1; }
pip3 install dist/pyroute2.ndb-* || { echo 'Failed' ; exit 1; }
pip3 install dist/pyroute2.nftables-* || { echo 'Failed' ; exit 1; }
pip3 install dist/pyroute2.nslink-* || { echo 'Failed' ; exit 1; }
pip3 install dist/pyroute2.protocols-* || { echo 'Failed' ; exit 1; }
pip3 install dist/pyroute2-* || { echo 'Failed' ; exit 1; }

# Setup pynat
pip3 install six || { echo 'Failed' ; exit 1; }
cd ${REPOS_FOLDER}/pynat || { echo 'Failed' ; exit 1; }
python3 setup.py install || { echo 'Failed' ; exit 1; }

# Setup data plane
cd ${REPOS_FOLDER}/srv6-sdn-data-plane || { echo 'Failed' ; exit 1; }
python3 setup.py install || { echo 'Failed' ; exit 1; }

# Setup and build protos
cd ${REPOS_FOLDER}/srv6-sdn-proto || { echo 'Failed' ; exit 1; }
python3 setup.py install || { echo 'Failed' ; exit 1; }

# Setup authentication utils
cd ${REPOS_FOLDER}/srv6-sdn-authentication || { echo 'Failed' ; exit 1; }
python3 setup.py install || { echo 'Failed' ; exit 1; }

# Setup STAMP utils
cd ${REPOS_FOLDER}/srv6pm-delay-measurement || { echo 'Failed' ; exit 1; }
python3 setup.py install || { echo 'Failed' ; exit 1; }

# Create folder for config files
mkdir -p /etc/everyedge || { echo 'Failed' ; exit 1; }

# Setup iptables and libpcap
apt-get install -y iptables libpcap-dev || { echo 'Failed' ; exit 1; }
# update-alternatives --set ip6tables /usr/sbin/ip6tables-nft || { echo 'Failed' ; exit 1; }

# Generate and export the device information file
CREATE_DEVICE_INFO_FILE="N"
if [ -f "${DEVICE_INFO_FILENAME}" ]; then
    echo "The device info file ${DEVICE_INFO_FILENAME} exists."
    echo "Overwrite it? [Y/n]"
    read ANSWER
    case $ANSWER in
        [yY]) CREATE_DEVICE_INFO_FILE="Y" ;;
        [nN]) CREATE_DEVICE_INFO_FILE="N" ;;
    esac
else 
    CREATE_DEVICE_INFO_FILE="Y"
fi

if [ "${CREATE_DEVICE_INFO_FILE}" = "Y" ]; then
    DEVICE_INFO='{"id":"","features":[{"name":"gRPC","port":12345},{"name":"SSH","port":22}]}'
    jq -n ${DEVICE_INFO} > "${DEVICE_INFO_FILENAME}" || { echo 'Failed' ; exit 1; }
fi

# Generate a default config file
CREATE_CONFIG_FILE="N"
if [ -f "${CONFIG_FILENAME}" ]; then
    echo "The configuration file ${CONFIG_FILENAME} exists."
    echo "Overwrite it? [Y/n]"
    read ANSWER
    case $ANSWER in
        [yY]) CREATE_CONFIG_FILE="Y" ;;
        [nN]) CREATE_CONFIG_FILE="N" ;;
    esac
else 
    CREATE_CONFIG_FILE="Y"
fi

if [ "${CREATE_CONFIG_FILE}" = "Y" ]; then
cat << EOF > "${CONFIG_FOLDER}"/config.ini
[DEFAULT]
device_config_file = ${DEVICE_INFO_FILENAME}
nat_discovery_server_ip = 2607:5300:201:3100::6a8f
nat_discovery_client_ip = ::
pymerang_server_ip = ${CONTROLLER_IP}
pymerang_server_port = ${CONTROLLER_PORT}
token_file = /etc/everyedge/token
public_prefix_length = 128
;public_prefix_length = 64
;sid_prefix = fc00::/64
debug = true
EOF
fi

# Create a starter script for the EveryEdge
cat << EOF > ${STARTER_FILENAME}
#!/usr/bin/bash

if [ "\$EUID" -ne 0 ]
  then echo "EveryEdge must run as root."
  exit
fi

# Activate the EveryEdge virtual environment
source ${VENV_ACTIVATE_SCRIPT}

# Start the EveryEdge
python3 -m srv6_sdn_data_plane.ew_edge_device -c /etc/everyedge/config.ini
EOF

# Remove temporary files
rm -rf ${REPOS_FOLDER} || { echo 'Failed' ; exit 1; }
