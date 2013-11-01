
Device server that acts as an API translation layer between raw TCP
socket binary protocol for devices and JSON API for the Rails app.

##### Table of Contents

* [Server](#server)
* [Vagrant](#vagrant)
* [Message Format](#message_format)
* [Message Flow](#message_flow)
  * [API Version](#api_version)
  * [Activation](#activation)
  * [Device Status](#device_status)
  * [Device Settings](#device_settings)
  * [Temperature Profiles](#temp_profiles)
* [Response Codes](#response_codes)

<a name='server'>
# Server

Configurtion is in `config.rb`

Settings are:

* HOST - Host IP to listen on
* DEVICE\_PORT - Port that devices should connect on
* WEB\_PORT - Port that accepts web calls for REST API
* ENDIAN - Endianness of the binary protocol

<a name='vagrant'>
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

<a name='message_format'>
# Message Format

```
| START_MESSAGE | MESSAGE_TYPE | DATA_LENGTH |   DATA   |   CRC   |
|      U24      |       U8     |      U32    | Variable |   U16   |
```

### Message Types

```
:TODO:
```

<a name='message_flow'>
# Message Flow

<a name='api_version'>
## API Version

Device specifies which API version it supports

### Data Flow

```

  Device                                                 Device Server
    +                                                          +
    |                                                          |
    |                                                          |
    |              Device Sends API Version It's Using         |
    |+-------------------------------------------------------->|
    |          Data: { Device Id, Version }                    |
    |                                                          |
    |                 Server Responds with ACK                 |
    |<--------------------------------------------------------+|
    |               Data: { Response Code }                    |
    |                                                          |
```

### API Version Packet

```
| Device ID | API VERSION |
|    U64    |       U8    |
```

<a name='ack'>
## ACK
Response packet with response code

### ACK Packet

```
| RESPONSE CODE |
|      U32      |
```

<a name='activation'>
## Activation

Activation flow for the device

### Data Flow

```
  Device                                                 Device Server
    +                                                          +
    |         Device Sends Request For Activation Token        |
    |+-------------------------------------------------------->|
    |               Data: { Device ID }                        |
    |                                                          |
    |                                                          |
    |      Server Responds with Token for Activation           |
    |<--------------------------------------------------------+|
    |              Data: { Activation Token }                  |
    |                                                          |
    |                                                          |
    |      Device Sends Request For Authentication Token       |
    |+-------------------------------------------------------->|
    |         Data: { Device ID, Activation Token }            |
    |                                                          |
    |                                                          |
    |      Server Responds with Authentication Token           |
    |<--------------------------------------------------------+|
    |              Data: { Authentication Token }              |
```

### Activation Request Packet

```
| DEVICE ID |
|    U64    |
```

A unique identifier for that device.

### Activation Token Packet

```
| ACTIVATION TOKEN |
|       U48        |
```

A unique activation token that experies after a short time.

### Authentication Token Packet

```
| AUTHENTICATION TOKEN |
|        U160          |
```

A unique authentication token specific to the user's account

<a name='device_status'>
## Device Status
Provides current temperature and device status, e.g. WiFi signal
strength

### Data Flow

```

  Device                                                 Device Server
    +                                                          +
    |                                                          |
    |                                                          |
    |              Device Sends Status Information             |
    |+-------------------------------------------------------->|
    |          Data: { authentication token, device id,        |
    |                  timestamp, status info }                |
    |                                                          |
    |                                                          |
    |                 Server Responds with ACK                 |
    |<--------------------------------------------------------+|
    |               Data: { ACK, Response Code }               |
    |                                                          |
```

### Status Packet

```
| AUTHENTICATION TOKEN | DEVICE ID | TIMESTAMP |  SETTINGS DATA  |
|          U160        |    U64    |    U32    | Variable Length |
```

#### Status Info

```
WIFI STRENGTH               | U32 (Scaled Integer, 100 factor)
NUMBER OF PROBES            | U32
PROBE TEMPERATURE VALUE 1   | U32 (Scaled Integer, 100 factor)
...
PROBE TEMPERATURE VALUE N   | U32 (Scaled Integer, 100 factor)
```

<a name='device_settings'>
## Device Settings
Provides getting and setting device settings.

### Data Flow

#### From Device, To Server

```

  Device                                                 Device Server
    +             Device Information From Device               +
    |                                                          |
    |                                                          |
    |              Device Sends Updated Info                   |
    |+-------------------------------------------------------->|
    |          Data: { authentication token, device id,        |
    |                  timestamp, settings }                   |
    |                                                          |
    |                 Server Responds with ACK                 |
    |<--------------------------------------------------------+|
    |               Data: { ACK, Response Code }               |
    |                                                          |
```

#### From Server, To Device

```
  Device                                                 Device Server
    +               User Makes Changes On Server               +
    |                                                          |
    |                                                          |
    |              Server Sends Updated Setting(s)             |
    |+-------------------------------------------------------->|
    |          Data: { authentication token, device id,        |
    |                  timestamp, settings }                   |
    |                                                          |
    |                 Server Responds with ACK                 |
    |<--------------------------------------------------------+|
    |               Data: { ACK, Response Code }               |
    |                                                          |
```

### Settings Packet

```
| AUTHENTICATION TOKEN | DEVICE ID | TIMESTAMP |  SETTINGS DATA  |
|          U160        |    U64    |    U32    | Variable Length |
```

#### Settings data

```
DEVICE NAME LENGTH        | U8
DEVICE NAME               | String, 100 chars max
TEMPERATURE SCALE         | U8
OUTPUT 1 FUNCTION         | U8
OUTPUT 1 TRIGGER (SENSOR) | U8
OUTPUT 1 SETPOINT         | U32 (Scaled Integer, 100 factor)
OUTPUT 1 COMPRESSOR DELAY | U32 (Scaled Integer, 100 factor)
OUTPUT 2 FUNCTION         | U8
OUTPUT 2 TRIGGER (SENSOR) | U8
OUTPUT 2 SETPOINT         | U32 (Scaled Integer, 100 factor)
OUTPUT 2 COMPRESSOR DELAY | U32 (Scaled Integer, 100 factor)
```

<a name='temp_profiles'>
## Temperature Profiles

Sending temperature profiles to the device

### Data Flow

```

  Device                                                 Device Server
    +                                                          +
    |                                                          |
    |                                                          |
    |             Server Send Temperature Profile              |
    |+-------------------------------------------------------->|
    |       Data: { Auth Token, Device ID,                     |
    |               Timestamp, Temperature Profile Data }      |
    |                                                          |
    |                 Server Responds with ACK                 |
    |<--------------------------------------------------------+|
    |               Data: { ACK, Response Code }               |
    |                                                          |
```

### Profile Packet

```
| AUTHENTICATION TOKEN | DEVICE ID | TIMESTAMP |  TEMPERATURE PROFILE  |
|          U160        |    U64    |    U32    |    Variable Length    |
```

### Temperature Profile Data
```
PROFILE NAME LENGTH     | U8
PROFILE NAME            | String, 100 chars max
PROFILE TYPE            | U8
NUMBER OF POINTS        | U32
POINT 1 OFFSET          | U32
POINT 1 TRANSITION TYPE | U8
POINT 1 TEMPERATURE     | U32 (Scaled Integer, 100 factor)
...
POINT N OFFSET          | U32
POINT N TRANSITION TYPE | U8
POINT N TEMPERATURE     | U32 (Scaled Integer, 100 factor)
```

<a name='response_codes'>
# Response Codes

```
SUCCESS                     | 0
ACTIVATION TOKEN NOT FOUND  | 1
```

