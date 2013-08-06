
Device server that acts as an API translation layer between raw TCP
socket binary protocol for devices and JSON API for the Rails app.

# Server

Configurtion is in `config.rb`

Settings are:

* HOST - Host IP to listen on
* DEVICE\_PORT - Port that devices should connect on
* WEB\_PORT - Port that accepts web calls for REST API
* ENDIAN - Endianness of the binary protocol

# To Use Vagrant for development

## Setup

1. Install [VirtualBox](https://www.virtualbox.org/)
2. Install [Vagrant](http://www.vagrantup.com/)

## Get the VM up and running

```
vagrant up
```

This will download the box and provision the VM

## Setup the server

```
vagrant ssh
cd /vagrant
bundle install
./server
```

At this point the server is running on ports defined in `config.rb`

## Talking to server

You can make connections to localshot:<port>

# Message Format

```
START_MESSAGE | MESSAGE_TYPE | DATA_LENGTH |   DATA   |   CRC
   3 Bytes    |   1 Byte     |  4 Bytes    | Variable | 2 Bytes
```
