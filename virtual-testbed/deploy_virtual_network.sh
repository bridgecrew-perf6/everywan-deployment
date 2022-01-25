#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "This script must run as root."
  exit
fi

usage() {
	echo "Usage: $0 [-d <deployment-dir>]" 1>&2
  exit 1
}

while getopts ":d" opt
do
    case $opt in
        d) DEPLOYMENT_DIR="${OPTARG}" ;;
        *) usage ;;
    esac
done

if [ -z "$DEPLOYMENT_DIR" ]
then
   DEPLOYMENT_DIR="/opt"
fi

# Paths
#CONFIG_FOLDER="/etc/everyedge"
#CONFIG_FILENAME="${CONFIG_FOLDER}/config.ini"
# DEVICE_INFO_FILENAME="${CONFIG_FOLDER}/device-info.json"
EVERYWAN_FOLDER="${DEPLOYMENT_DIR}/everywan"
VENV_FOLDER="${EVERYWAN_FOLDER}/everywan-venv"
VENV_ACTIVATE_SCRIPT="${VENV_FOLDER}/bin/activate"
STARTER_FILENAME="${EVERYWAN_FOLDER}/srv6-sdn-mininet/starter.sh"
REPOS_FOLDER="/tmp/everywan-repos"

# Update the package lists
apt-get update || { echo 'Failed' ; exit 1; }

# Install dependencies
DEBIAN_FRONTEND="noninteractive" apt-get install -y git python3 python3-pip jq libffi-dev libssl-dev  graphviz graphviz-dev || { echo 'Failed' ; exit 1; }

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

# Create EveryEdge folder
mkdir -p ${EVERYWAN_FOLDER}

# Download public key for github.com
mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts || { echo 'Failed' ; exit 1; }

# Download public key for bitbucket.org
mkdir -p -m 0600 ~/.ssh && ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts || { echo 'Failed' ; exit 1; }

# Create a temporary folder to download repositories
mkdir -p ${REPOS_FOLDER} || { echo 'Failed' ; exit 1; }

# Clone the repositories
git clone git@github.com:cscarpitta/pynat.git ${REPOS_FOLDER}/pynat || { echo 'Failed' ; exit 1; }
git clone git@github.com:everywan-io/srv6-sdn-data-plane.git --branch experimental/dockerize-everyedge  ${REPOS_FOLDER}/srv6-sdn-data-plane || { echo 'Failed' ; exit 1; }
git clone git@github.com:everywan-io/srv6-sdn-proto.git --branch experimental/dockerize-controller  ${REPOS_FOLDER}/srv6-sdn-proto || { echo 'Failed' ; exit 1; }
git clone git@github.com:everywan-io/srv6-sdn-authentication.git --branch experimental/dockerize-everyedge  ${REPOS_FOLDER}/srv6-sdn-authentication || { echo 'Failed' ; exit 1; }
git clone git@github.com:cscarpitta/srv6pm-delay-measurement.git --branch feature/align-to-mgmt-plane  ${REPOS_FOLDER}/srv6pm-delay-measurement || { echo 'Failed' ; exit 1; }
git clone git@github.com:everywan-io/srv6-sdn-control-plane.git --branch experimental/dockerize-controller ${REPOS_FOLDER}/srv6-sdn-control-plane || { echo 'Failed' ; exit 1; }
git clone git@github.com:everywan-io/srv6-sdn-openssl.git ${REPOS_FOLDER}/srv6-sdn-openssl || { echo 'Failed' ; exit 1; }
git clone git@github.com:everywan-io/srv6-sdn-controller-state.git --branch experimental-dockerize-controller ${REPOS_FOLDER}/srv6-sdn-controller-state || { echo 'Failed' ; exit 1; }
git clone git@bitbucket.org:pierventre/srv6-properties-generators.git --branch carmine ${REPOS_FOLDER}/srv6-properties-generators || { echo 'Failed' ; exit 1; }
git clone git@github.com:everywan-io/srv6-sdn-mininet.git --branch ipv6-support ${EVERYWAN_FOLDER}/srv6-sdn-mininet || { echo 'Failed' ; exit 1; }

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

# Setup control plane
cd ${REPOS_FOLDER}/srv6-sdn-control-plane || { echo 'Failed' ; exit 1; }
python3 setup.py install || { echo 'Failed' ; exit 1; }

# Setup openssl utils
cd ${REPOS_FOLDER}/srv6-sdn-openssl || { echo 'Failed' ; exit 1; }
python3 setup.py install || { echo 'Failed' ; exit 1; }

# Setup controller storage utils
cd ${REPOS_FOLDER}/srv6-sdn-controller-state || { echo 'Failed' ; exit 1; }
python3 setup.py install || { echo 'Failed' ; exit 1; }

# Setup properties generators
cd ${REPOS_FOLDER}/srv6-properties-generators || { echo 'Failed' ; exit 1; }
python3 setup.py install || { echo 'Failed' ; exit 1; }


# Create folder for config files
#mkdir -p /etc/everyedge || { echo 'Failed' ; exit 1; }

# Setup iptables and libpcap
apt-get install -y iptables libpcap-dev || { echo 'Failed' ; exit 1; }
# update-alternatives --set ip6tables /usr/sbin/ip6tables-nft || { echo 'Failed' ; exit 1; }


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
cd ${EVERYWAN_FOLDER}/srv6-sdn-mininet
python3 ./srv6_mininet_extension.py --topo topo/topology_h_multisub_ipv6.json
EOF

# Remove temporary files
rm -rf ${REPOS_FOLDER} || { echo 'Failed' ; exit 1; }
