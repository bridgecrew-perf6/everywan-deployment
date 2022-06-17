# EveryWAN Development

This repositories contains instructions to build a development environment for EveryWAN.

## Prerequisites
* git
* Docker Engine (https://docs.docker.com/engine/install/)
* Docker Compose (https://docs.docker.com/compose/install/)

## Installation

### Management Infrastructure (MongoDB, MariaDB, Keystone)

Clone the EveryWAN Dockerized repository:

```bash
$ git clone https://github.com/everywan-io/everywan-dockerized
```

`cd` to the repository folder:

```bash
$ cd everywan-dockerized
```

Build and run the Docker containers:

```bash
$ docker-compose build
```

### EveryBOSS (EveryWAN Orchestrator)

Install pipenv:

```bash
$ apt-get install pipenv
```

Clone the EveryBOSS repository:

```bash
$ git clone https://github.com/everywan-io/EveryBOSS --branch deployment
```

`cd` to the repository folder:

```bash
$ cd EveryBOSS
```

Install the dependencies required to run EveryBOSS:

```bash
$ pipenv --python /usr/bin/python3 install
```

Activate the EveryBOSS virtual environment created by pipenv:

```bash
$ pipenv shell
(EveryBOSS-7G2aSQtE)$
```

Install the required dependencies in the EveryBOSS virtual environment:

```bash
(EveryBOSS-7G2aSQtE)$ pip install git+https://github.com/everywan-io/srv6-sdn-control-plane.git@experimental/dockerize-controller
```

```bash
(EveryBOSS-7G2aSQtE)$ pip install git+https://github.com/everywan-io/srv6-sdn-proto.git@experimental/dockerize-controller
```

```bash
(EveryBOSS-7G2aSQtE)$ pip install git+https://github.com/everywan-io/srv6pm-delay-measurement.git@feature/align-to-mgmt-plane
```

```bash
(EveryBOSS-7G2aSQtE)$ pip install git+https://bitbucket.org/pierventre/srv6-properties-generators.git@carmine
```

### EveryGUI (EveryWAN Orchestrator)

Clone the EveryGUI repository:

```bash
$ git clone https://github.com/everywan-io/EveryGUI --branch deployment
```

`cd` to the repository folder:

```bash
$ cd EveryGUI
```

Install the required dependencies:

```bash
$ apt-get install nodejs
$ apt-get install npm
$ npm install bootstrap
$ npm install -g @angular/cli
$ apt-get install nodejs
$ npm install
```

### Virtual Testbed

EveryWAN includes a set of tools to run EveryWAN in a fully virtual testbed. This is particularly useful for development purposes.


Since it is not mandatory, it is strongly suggested to install and run the EveryWAN modules in a Python virtual environment.

To create a virtual environment, run the following command:

```bash
$ python3 -m venv everywan-venv
```

To activate the virtual environment:

```bash
source everywan-venv/bin/activate
```

#### EveryEdgeOS (EveryWAN controller)

Clone the repositories required to run EveryEdgeOS:

```bash
$ git clone https://github.com/cscarpitta/pynat.git
$ git clone https://github.com/everywan-io/srv6-sdn-control-plane.git --branch experimental/dockerize-controller
$ git clone https://github.com/everywan-io/srv6-sdn-proto.git --branch experimental/dockerize-controller
$ git clone https://github.com/everywan-io/srv6-sdn-openssl.git
$ git clone https://github.com/everywan-io/srv6-sdn-controller-state.git --branch experimental-dockerize-controller
$ git clone https://github.com/everywan-io/srv6-sdn-authentication.git --branch experimental/dockerize-everyedge
$ git clone https://github.com/cscarpitta/srv6pm-delay-measurement.git --branch feature/align-to-mgmt-plane
$ git clone https://bitbucket.org/pierventre/srv6-properties-generators.git --branch carmine
```

Update package lists:

```bash
$ apt-get update
```

Install dependencies:

```bash
$ DEBIAN_FRONTEND="noninteractive" apt-get install -y graphviz graphviz-dev python3 python3-pip
```

If you are working in a Python virtual environment, you need to activate the virtual environment before installing the Python packages:

```bash
source everywan-venv/bin/activate
```

Install the Python dependencies:

```bash
$ pip install protobuf==3.19.1
```

Install EveryWAN Python modules in development mode.

Setup pynat:

```bash
(everywan-venv)$ pip install six
(everywan-venv)$ cd pynat
(everywan-venv)$ python setup.py develop
```

Setup control plane:

```bash
(everywan-venv)$ cd srv6-sdn-control-plane
(everywan-venv)$ python setup.py develop
```

Setup and build protos:

```bash
(everywan-venv)$ cd srv6-sdn-proto
(everywan-venv)$ python setup.py develop
```

Setup openssl utils:

```bash
(everywan-venv)$ cd srv6-sdn-openssl
(everywan-venv)$ python setup.py develop
```

Setup database utils:

```bash
(everywan-venv)$ cd srv6-sdn-controller-state
(everywan-venv)$ python setup.py develop
```

Setup authentication utils:

```bash
(everywan-venv)$ cd srv6-sdn-authentication
(everywan-venv)$ python setup.py develop
```

Setup STAMP utils:

```bash
(everywan-venv)$ cd srv6pm-delay-measurement
(everywan-venv)$ python setup.py develop
```

Setup properties generators:

```bash
(everywan-venv)$ cd srv6-properties-generators
(everywan-venv)$ python setup.py develop
```


#### EveryEdge Device

Clone the repositories required to run EveryEdgeOS:

```bash
$ git clone https://github.com/cscarpitta/pynat.git
$ git clone https://github.com/everywan-io/srv6-sdn-data-plane.git --branch experimental/dockerize-everyedge
$ git clone https://github.com/everywan-io/srv6-sdn-proto.git --branch experimental/dockerize-controller
$ git clone https://github.com/everywan-io/srv6-sdn-authentication.git --branch experimental/dockerize-everyedge
$ git clone https://github.com/cscarpitta/srv6pm-delay-measurement.git --branch feature/align-to-mgmt-plane
```

Update package lists:

```bash
$ apt-get update
```

Install dependencies:

```bash
$ DEBIAN_FRONTEND="noninteractive" apt-get install -y python3 python3-pip jq
```

If you are working in a Python virtual environment, you need to activate the virtual environment before installing the Python packages:

```bash
source everywan-venv/bin/activate
```

Install the Python dependencies:

```bash
(everywan-venv)$ pip install protobuf==3.19.1 pyroute2
```

Install a patched version of pyroute2:

```bash
(everywan-venv)$ pip install twine
(everywan-venv)$ git clone https://github.com/cscarpitta/pyroute2.git --branch srv6_end_dt4 /tmp/pyroute2
(everywan-venv)$ cd /tmp/pyroute2
(everywan-venv)$ make dist python=python3
(everywan-venv)$ pip install dist/pyroute2.core-*
(everywan-venv)$ pip install dist/pyroute2.ethtool-*
(everywan-venv)$ pip install dist/pyroute2.ipdb-*
(everywan-venv)$ pip install dist/pyroute2.ipset-*
(everywan-venv)$ pip install dist/pyroute2.minimal-*
(everywan-venv)$ pip install dist/pyroute2.ndb-*
(everywan-venv)$ pip install dist/pyroute2.nftables-*
(everywan-venv)$ pip install dist/pyroute2.nslink-*
(everywan-venv)$ pip install dist/pyroute2.protocols-*
(everywan-venv)$ pip install dist/pyroute2-*
```

Install EveryWAN Python modules in development mode.

Setup pynat:

```bash
(everywan-venv)$ pip install six
(everywan-venv)$ cd pynat
(everywan-venv)$ python setup.py develop
```

Setup data plane:

```bash
(everywan-venv)$ cd srv6-sdn-data-plane
(everywan-venv)$ python setup.py develop
```

Setup and build protos:

```bash
(everywan-venv)$ cd srv6-sdn-proto
(everywan-venv)$ python setup.py develop
```

Setup authentication utils:

```bash
(everywan-venv)$ cd srv6-sdn-authentication
(everywan-venv)$ python setup.py develop
```

Setup STAMP utils:

```bash
(everywan-venv)$ cd srv6pm-delay-measurement
(everywan-venv)$ python setup.py develop
```


#### Mininet Emulator

Clone the following repositories:

```bash
$ git clone https://bitbucket.org/pierventre/srv6-properties-generators.git --branch carmine
$ git clone https://bitbucket.org/ssalsano/dreamer-topology-parser-and-validator.git --branch carmine
$ git clone https://github.com/everywan-io/srv6-sdn-mininet --branch add_ipv6_support
```

Install Mininet:

```bash
$ apt-get install mininet
```

If you are working in a Python virtual environment, you need to activate the virtual environment before installing the Python packages:

```bash
$ source everywan-venv/bin/activate
```

Setup SRv6 Properties Generators:

```bash
(everywan-venv)$ cd srv6-properties-generators
(everywan-venv)$ python setup.py develop
```

Setup Topology Parser and Validator:

```bash
(everywan-venv)$ cd dreamer-topology-parser-and-validator
(everywan-venv)$ python setup.py develop
```

Install the FRRouting Suite:

```bash
# Add GPG key for frr
$ curl -s https://deb.frrouting.org/frr/keys.asc | apt-key add -

# frr-stable will be the latest official stable release
$ echo deb https://deb.frrouting.org/frr focal frr-stable | tee -a /etc/apt/sources.list.d/frr.list

# Update and install FRR
$ apt-get update
$ apt install -y frr frr-pythontools
```

Install Mininet:

```bash
(everywan-venv)$ pip install mininet
```

Install Etherws Python library:

```bash
(everywan-venv)$ pip install etherws
```

Setup SRv6 Properties Generators:

```bash
cd srv6-properties-generators
(everywan-venv)$ python setup.py install
```

Setup Dreamer Topology Parser and Validator:

```bash
cd dreamer-topology-parser-and-validator
(everywan-venv)$ python setup.py install
```

Setup FRR daemons properly:

```bash
$ update-alternatives --install /usr/bin/zebra zebra /lib/frr/zebra 1
$ update-alternatives --install /usr/bin/ospfd ospfd /lib/frr/ospfd 1
$ update-alternatives --install /usr/bin/ospf6d ospf6d /lib/frr/ospf6d 1
$ update-alternatives --install /usr/bin/staticd staticd /lib/frr/staticd 1
```


## Run the Development Environment

### Management Infrastructure (MongoDB, MariaDB, Keystone)

To start the management infrastructure, `cd` to the everywan-dockerized folder:

```bash
$ cd everywan-dockerized
```

Run the Docker containers (MongoDB, MariaDB, Keystone):

```bash
$ docker-compose up
```

### EveryBOSS (EveryWAN Orchestrator)

To start the EveryBOSS, `cd` to the EveryBOSS folder:

```bash
$ cd EveryBOSS
```

Activate the Python virtual environment:

```bash
$ pipenv shell
(EveryBOSS-7G2aSQtE)$
```

Run the EveryBOSS (Flask server):

```bash
CONTROLLER_IP=<controller_ip> sh ./run_dev_env.sh
```

where <controller_ip> is the IP address of the EveryWAN controller.

For example,

```bash
CONTROLLER_IP=2000:0:25:24::1 sh ./run_dev_env.sh
```

### EveryGUI (EveryWAN Orchestrator)

To run the EveryGUI in development mode, `cd` to the EveryGUI folder:

```bash
$ cd EveryGUI
```

Then, build and serve the EveryGUI:

```bash
$ ng serve -c local
```

### Virtual Testbed

`cd` to the srv6-sdn-mininet folder:

```bash
$ cd srv6-sdn-mininet
```

The `topo` folder contains some example topology. You can emulate one of the sample topology or you can create your own topology.

If you have installed the EveryWAN Python modules in a virtual environment, you need to activate the virtual environment:

```bash
$ source everywan-venv/bin/activate
```

To emulate a topology, you can execute the following command:

```bash
$ python ./srv6_mininet_extension.py --topo <topology_json>
```

where <topology_json> is the path to the topology to emulate (in JSON format).

For example,

```bash
$ python ./srv6_mininet_extension.py --topo topo/topology_h_multisub_ipv6.json
```









EveryWAN includes a set of tools to run EveryWAN in a fully virtual testbed. This is particularly useful for development purposes.


Since it is not mandatory, it is strongly suggested to install and run the EveryWAN modules in a Python virtual environment.

To create a virtual environment, run the following command:

```bash
$ python3 -m venv everywan-venv
```

To activate the virtual environment:

```bash
$ source everywan-venv/bin/activate
```

#### EveryEdgeOS (EveryWAN controller)

Clone the repositories required to run EveryEdgeOS:

```bash
$ git clone https://github.com/cscarpitta/pynat.git
$ git clone https://github.com/everywan-io/srv6-sdn-control-plane.git --branch experimental/dockerize-controller
$ git clone https://github.com/everywan-io/srv6-sdn-proto.git --branch experimental/dockerize-controller
$ git clone https://github.com/everywan-io/srv6-sdn-openssl.git
$ git clone https://github.com/everywan-io/srv6-sdn-controller-state.git --branch experimental-dockerize-controller
$ git clone https://github.com/everywan-io/srv6-sdn-authentication.git --branch experimental/dockerize-everyedge
$ git clone https://github.com/cscarpitta/srv6pm-delay-measurement.git --branch feature/align-to-mgmt-plane
$ git clone https://bitbucket.org/pierventre/srv6-properties-generators.git --branch carmine
```

Update package lists:

```bash
$ apt-get update
```

Install dependencies:

```bash
$ DEBIAN_FRONTEND="noninteractive" apt-get install -y graphviz graphviz-dev python3 python3-pip
```

If you are working in a Python virtual environment, you need to activate the virtual environment before installing the Python packages:

```bash
source everywan-venv/bin/activate
```

Install the Python dependencies:

```bash
$ pip install protobuf==3.19.1
```

Install EveryWAN Python modules in development mode.

Setup pynat:

```bash
(everywan-venv)$ pip install six
(everywan-venv)$ cd pynat
(everywan-venv)$ python setup.py develop
```

Setup control plane:

```bash
(everywan-venv)$ cd srv6-sdn-control-plane
(everywan-venv)$ python setup.py develop
```

Setup and build protos:

```bash
(everywan-venv)$ cd srv6-sdn-proto
(everywan-venv)$ python setup.py develop
```

Setup openssl utils:

```bash
(everywan-venv)$ cd srv6-sdn-openssl
(everywan-venv)$ python setup.py develop
```

Setup database utils:

```bash
(everywan-venv)$ cd srv6-sdn-controller-state
(everywan-venv)$ python setup.py develop
```

Setup authentication utils:

```bash
(everywan-venv)$ cd srv6-sdn-authentication
(everywan-venv)$ python setup.py develop
```

Setup STAMP utils:

```bash
(everywan-venv)$ cd srv6pm-delay-measurement
(everywan-venv)$ python setup.py develop
```

Setup properties generators:

```bash
(everywan-venv)$ cd srv6-properties-generators
(everywan-venv)$ python setup.py develop
```


#### EveryEdge Device

Clone the repositories required to run EveryEdgeOS:

```bash
$ git clone https://github.com/cscarpitta/pynat.git
$ git clone https://github.com/everywan-io/srv6-sdn-data-plane.git --branch experimental/dockerize-everyedge
$ git clone https://github.com/everywan-io/srv6-sdn-proto.git --branch experimental/dockerize-controller
$ git clone https://github.com/everywan-io/srv6-sdn-authentication.git --branch experimental/dockerize-everyedge
$ git clone https://github.com/cscarpitta/srv6pm-delay-measurement.git --branch feature/align-to-mgmt-plane
```

Update package lists:

```bash
$ apt-get update
```

Install dependencies:

```bash
$ DEBIAN_FRONTEND="noninteractive" apt-get install -y python3 python3-pip jq
```

If you are working in a Python virtual environment, you need to activate the virtual environment before installing the Python packages:

```bash
source everywan-venv/bin/activate
```

Install the Python dependencies:

```bash
(everywan-venv)$ pip install protobuf==3.19.1 pyroute2
```

Install a patched version of pyroute2:

```bash
(everywan-venv)$ pip install twine
(everywan-venv)$ git clone https://github.com/cscarpitta/pyroute2.git --branch srv6_end_dt4 /tmp/pyroute2
(everywan-venv)$ cd /tmp/pyroute2
(everywan-venv)$ make dist python=python3
(everywan-venv)$ pip install dist/pyroute2.core-*
(everywan-venv)$ pip install dist/pyroute2.ethtool-*
(everywan-venv)$ pip install dist/pyroute2.ipdb-*
(everywan-venv)$ pip install dist/pyroute2.ipset-*
(everywan-venv)$ pip install dist/pyroute2.minimal-*
(everywan-venv)$ pip install dist/pyroute2.ndb-*
(everywan-venv)$ pip install dist/pyroute2.nftables-*
(everywan-venv)$ pip install dist/pyroute2.nslink-*
(everywan-venv)$ pip install dist/pyroute2.protocols-*
(everywan-venv)$ pip install dist/pyroute2-*
```

Install EveryWAN Python modules in development mode.

Setup pynat:

```bash
(everywan-venv)$ pip install six
(everywan-venv)$ cd pynat
(everywan-venv)$ python setup.py develop
```

Setup data plane:

```bash
(everywan-venv)$ cd srv6-sdn-data-plane
(everywan-venv)$ python setup.py develop
```

Setup and build protos:

```bash
(everywan-venv)$ cd srv6-sdn-proto
(everywan-venv)$ python setup.py develop
```

Setup authentication utils:

```bash
(everywan-venv)$ cd srv6-sdn-authentication
(everywan-venv)$ python setup.py develop
```

Setup STAMP utils:

```bash
(everywan-venv)$ cd srv6pm-delay-measurement
(everywan-venv)$ python setup.py develop
```


#### Mininet Emulator

Clone the following repositories:

```bash
$ git clone https://bitbucket.org/pierventre/srv6-properties-generators.git --branch carmine
$ git clone https://bitbucket.org/ssalsano/dreamer-topology-parser-and-validator.git --branch carmine
$ git clone https://github.com/everywan-io/srv6-sdn-mininet --branch add_ipv6_support
```

Install Mininet:

```bash
$ apt-get install mininet
```

If you are working in a Python virtual environment, you need to activate the virtual environment before installing the Python packages:

```bash
$ source everywan-venv/bin/activate
```

Setup SRv6 Properties Generators:

```bash
(everywan-venv)$ cd srv6-properties-generators
(everywan-venv)$ python setup.py develop
```

Setup Topology Parser and Validator:

```bash
(everywan-venv)$ cd dreamer-topology-parser-and-validator
(everywan-venv)$ python setup.py develop
```

Install the FRRouting Suite:

```bash
# Add GPG key for frr
$ curl -s https://deb.frrouting.org/frr/keys.asc | apt-key add -

# frr-stable will be the latest official stable release
$ echo deb https://deb.frrouting.org/frr focal frr-stable | tee -a /etc/apt/sources.list.d/frr.list

# Update and install FRR
$ apt-get update
$ apt install -y frr frr-pythontools
```

Install Mininet:

```bash
(everywan-venv)$ pip install mininet
```

Install Etherws Python library:

```bash
(everywan-venv)$ pip install etherws
```

Setup SRv6 Properties Generators:

```bash
cd srv6-properties-generators
(everywan-venv)$ python setup.py install
```

Setup Dreamer Topology Parser and Validator:

```bash
cd dreamer-topology-parser-and-validator
(everywan-venv)$ python setup.py install
```

Setup FRR daemons properly:

```bash
$ update-alternatives --install /usr/bin/zebra zebra /lib/frr/zebra 1
$ update-alternatives --install /usr/bin/ospfd ospfd /lib/frr/ospfd 1
$ update-alternatives --install /usr/bin/ospf6d ospf6d /lib/frr/ospf6d 1
$ update-alternatives --install /usr/bin/staticd staticd /lib/frr/staticd 1
```