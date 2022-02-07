#!/bin/bash

if [ "`id -r -u`" != "0" ]
then
  echo "This script must run as root"
  echo ""
  exit 1
fi

usage() {
	echo "Usage: $0 -n <num-hosts> -i <start-id>" 1>&2
  exit 1
}

while getopts ":n:i:" opt
do
    case $opt in
        n) NUM_HOSTS="${OPTARG}" ;;
        i) START_ID="${OPTARG}" ;;
        *) usage
			;;
    esac
done

if [ -z "$NUM_HOSTS" ]
then
   echo "Parameter -n <num-hosts> is missing";
   echo ""
   usage
fi

if [ -z "$START_ID" ]
then
   echo "Parameter -i <start-id> is missing. Using START_ID=1";
   echo ""
   START_ID=1
fi

for HOST in $(seq ${START_ID} $((${START_ID}+${NUM_HOSTS}-1)))
do
    echo ""
    echo "*************"
    echo "Setting up host ${HOST}"

    echo "Creating namespace for host ${HOST}"
    ip netns add ns-host-${HOST}

    echo "Connecting host namespace to the root namespace via a veth pair"
    ip link add veth1-host-${HOST} type veth peer name veth2-host-${HOST}
    ip link set veth2-host-${HOST} netns ns-host-${HOST}
    ip netns exec ns-host-${HOST} ip link set veth2-host-${HOST} up
    ip link set veth1-host-${HOST} up

    echo "Assigning an IPv4 address to the veth interfaces"
    ip netns exec ns-host-${HOST} ip addr add 192.168.${HOST}.2/24 dev veth2-host-${HOST}
    ip addr add 192.168.${HOST}.1/24 dev veth1-host-${HOST}

    echo "Setting up a default route"
    ip netns exec ns-host-${HOST} ip route add default via 192.168.${HOST}.1

    echo "Configuration for host ${HOST} completed"
    echo "*************"
    echo ""
done

echo "All the hosts have been configured"
echo ""

exit 0
