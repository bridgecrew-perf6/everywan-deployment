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
    echo "Destroying host ${HOST}"

    echo "Removing default route"
    ip netns exec ns-host-${HOST} ip route del default via 192.168.${HOST}.1

    echo "Removing IPv4 address from the veth interfaces"
    ip addr del 192.168.${HOST}.1/24 dev veth1-host-${HOST}
    ip netns exec ns-host-${HOST} ip addr del 192.168.${HOST}.2/24 dev veth2-host-${HOST}

    echo "Removing veth pair"
    ip link set veth1-host-${HOST} down
    ip netns exec ns-host-${HOST} ip link set veth2-host-${HOST} down
    ip netns exec ns-host-${HOST} ip link set veth2-host-${HOST} netns 1
    ip link del veth1-host-${HOST}

    echo "Removing namespace for host ${HOST}"
    ip netns del ns-host-${HOST}

    echo "Host ${HOST} removed"
    echo "*************"
    echo ""
done

echo "All the hosts have been removed"
echo ""

exit 0
