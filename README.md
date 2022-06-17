# EveryWAN Deployment

This repository contains some scripts to automate the deployment and configuration of the EveryWAN components both over a physical testbed and over a virtual testbed.


## Outline

1. [Physical Deployment](#physical-deployment)
    1. [EveryEdgeOS (EveryWAN controller) and management infrastructure](#everyedgeos-everywan-controller-and-management-infrastructure)
    2. [EveryEdge Device](#everyedge-device)
    3. [Virtual Hosts](#virtual-hosts)
2. [Virtual Testbed](#virtual-testbed)
    1. [Management Infrastructure](#management-infrastructure)
    2. [Virtual Network](#virtual-network)
3. [Development Environment](#development-environment)


## Physical Deployment

This section describes the steps required to deploy EveryWAN on a physical testbed. In order to deploy EveryWAN on a physical testbed you need a Linux machine (either a bare metal server or a Linux VM) publicly accessible where you can deploy the EveryWAN controller (named EveryEdgeOS) and all the management infrastructure (including the GUI).

Moreover you need to place a Linux machine (e.g. a Linux VM) in every site that you want to interconnect using EveryWAN. On these machines you need to deploy the EveryEdge software.


### EveryEdgeOS (EveryWAN controller) and management infrastructure

This section describe how to deploy the EveryEdgeOS and all the management containers as docker containers.

The Management Infrastructure comprises several components:
* EveryBOSS (EveryWAN orchestrator)
* EveryGUI (a NGINX web server that exposes a GUI to configure the EveryWAN devices and services)
* MongoDB (a database used to store information about the EveryWAN devices and services)
* Keystone (a component used for authentication functionalities)
* MariaDB (database used by Keystone)

#### Prerequisites

* Docker Engine (https://docs.docker.com/engine/install/)
* Docker Compose (https://docs.docker.com/compose/install/)

To deploy the EveryEdgeOS and the EveryWAN Management Infrastructure, clone this repository:

```bash
git clone https://github.com/everywan-io/everywan-deployment
```

Then, `cd` to the `physical-deployment` folder:

```bash
cd everywan-deployment/physical-deployment
```

Run the following command to build and run all the docker containers:

```bash
bash ./deploy_everywan_mgmt.sh
```

By default, the controller is reachable on the gRPC port 50061.

The GUI can be accessed by contacting the host on the HTTP port 80, e.g.:

```
http://localhost:80
```

### EveryEdge Device

#### Prerequisites

The following prerequisites are required to run the EveryWAN software:

* Linux kernel at least version 5.11
* Docker Engine (https://docs.docker.com/engine/install/)
* Docker Compose (https://docs.docker.com/compose/install/)

To deploy the EveryEdge software, clone this repository:

```bash
git clone https://github.com/everywan-io/everywan-deployment
```

Then, `cd` to the `physical-deployment` folder:

```bash
cd everywan-deployment/physical-deployment
```

Finally, run the following command to deploy the EveryEdge:

```bash
bash deploy_everyedge.sh [-c <controller-ip>] [-p <controller-port>] [-d <deployment-dir>]
```

where `controller-ip` and `controller-port` are the IP address and gRPC port of the controller, respectively, and `deployment-dir` is the path to the folder where you want to install the EveryEdge modules.

`controller-ip`, `controller-port` and `deployment-dir` are optional. The default values are:

```
controller-ip: 127.0.0.1
controller-port: 50061
deployment-dir: /opt/everyedge
```

The above command will create a Python virtual environment containing the EveryEdge components and the dependencies required to run the EveryEdge software.

EveryEdge comes with a default configuration file located at `/etc/everyedge/config.ini`. To customize the configuration, you can edit the file `/etc/everyedge/config.ini` with your favourite text editor.

Before running the EveryEdge, you need to provide the token required for the authentication. To retrieve the token, log in to the EveryWAN GUI with your credentials. You can find the token in the Tenant configuration page of the EveryWAN GUI.

Then, create a text file named `token` under the `/etc/everyedge` folder and store your token in the `token` file.

Finally, you can run the EveryEdge with the following command:

```bash
cd <deployment-dir>/everyedge
bash starter.sh
```

where `deployment-dir` is the path that you provided previously or `/opt/everyedge` if you didn't set any path.


### Virtual Hosts

You can emulate any number of hosts connected to the EveryEdge device using the Linux namespaces. Basically, the EveryEdge software is executed in the root network namespace. Each host lives in its own network namespace. To simulate the interconnections between the EveryEdge and the virtual hosts, each namespace need to be connected to the root namespace using a veth pair.

This repository contains a script that automates the above configuration. To emulate a number of hosts connected to the EveryEdge, you can run the following commands:

```bash
cd everywan-deployment
bash ./deploy_vhosts.sh -n <num-hosts>
```

For example, you can emulate 3 hosts with the following command:

```bash
cd everywan-deployment
bash ./deploy_vhosts.sh -n 3
```


## Virtual Testbed

This repository contains the tools required to run EveryWAN in a virtual testbed. The deployment tools will emulate a network using the Mininet emulator.

### Prerequisites
* Linux kernel at least version 5.11
* Docker Engine (https://docs.docker.com/engine/install/)
* Docker Compose (https://docs.docker.com/compose/install/)

### Virtual network

You can create a virtual network to emulate an arbitrary number of EveryEdge devices and provider routers. Virtual testbed includes all the EveryWAN components: EveryEdgeOS (controller), EveryEdge devices, management infrastructure (MongoDB, MariaDB, Keystone, EveryBOSS, EveryGUI).

To setup the tools required to emulate a virtual network, clone this repository:

```bash
git clone https://github.com/everywan-io/everywan-deployment
```

Then, `cd` to the `virtual-testbed` folder:

```bash
cd everywan-deployment/virtual-testbed
```

Finally, run the following command:

```bash
bash ./deploy_everywan_virtual.sh
```

To attach to the Mininet CLI and control your virtual network:

```bash
bash ./attach_to_mininet_cli.sh
```


## Development Environment

EveryWAN also integrates an open source development environment. This environment relies on an EveryWAN emulator based on the Mininet project that can be used to develop and test EveryWAN functionalities. To install and configure the development environment check the documentation [here](development-environment/README.md)