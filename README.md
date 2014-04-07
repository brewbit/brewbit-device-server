
<a name='development'></a>
# Development

Vagrant is used for Development

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

