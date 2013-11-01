
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
| START_MESSAGE | MESSAGE_TYPE | DATA_LENGTH |   DATA   |   CRC   |
|    3 Bytes    |   1 Byte     |  4 Bytes    | Variable | 2 Bytes |
```

# Message Flow

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
    |                                                          |
    |             Server Responds with ACK on Success          |
    |<--------------------------------------------------------+|
    |                      Data: { ACK }                       |
    |                                                          |
    |                                                          |
    |        Server Responds with NACK & Error Code on Error   |
    |<--------------------------------------------------------+|
    |                 Data: { NACK, error code }               |
    |                                                          |
    |                                                          |
```

### API Version Packet

```
| Device ID | API VERSION |
| 128 Bytes |   4 Bytes   |
```

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
| 128 Bytes |
```

A unique identifier for that device.

### Activation Token Packet

```
| ACTIVATION TOKEN |
|      6 Bytes     |
```

A unique activation token that experies after a short time.

### Authentication Token Packet

```
| AUTHENTICATION TOKEN |
|        20 Bytes      |
```

A unique authentication token specific to the user's account

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
    |             Server Responds with ACK on Success          |
    |<--------------------------------------------------------+|
    |                      Data: { ACK }                       |
    |                                                          |
    |                                                          |
    |        Server Responds with NACK & Error Code on Error   |
    |<--------------------------------------------------------+|
    |                 Data: { NACK, error code }               |
    |                                                          |
    |                                                          |
```

### Setting Packet

```
| AUTHENTICATION TOKEN | DEVICE ID | TIMESTAMP |  SETTINGS DATA  |
|       20 Bytes       | 128 Bytes |   Float   | Variable Length |
```

#### Status Info

```
WIFI STRENGTH               | Float
NUMBER OF PROBES            | 4 Bytes
PROBE TEMPERATURE VALUE 1   | Float
...
PROBE TEMPERATURE VALUE N   | Float
```

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
    |                                                          |
    |             Server Responds with ACK on Success          |
    |<--------------------------------------------------------+|
    |                      Data: { ACK }                       |
    |                                                          |
    |                                                          |
    |        Server Responds with NACK & Error Code on Error   |
    |<--------------------------------------------------------+|
    |                 Data: { NACK, error code }               |
    |                                                          |
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
    |                                                          |
    |                                                          |
    |             Device Responds with ACK on Success          |
    |<--------------------------------------------------------+|
    |                      Data: { ACK }                       |
    |                                                          |
    |                                                          |
    |        Device Responds with NACK & Error Code on Error   |
    |<--------------------------------------------------------+|
    |                 Data: { NACK, error code }               |
    |                                                          |
    |                                                          |
```

### Settings Packet

```
| AUTHENTICATION TOKEN | DEVICE ID | TIMESTAMP |  SETTINGS DATA  |
|       20 Bytes       | 128 Bytes |   Float   | Variable Length |
```

#### Settings data

```
DEVICE NAME LENGTH        | 1 Byte
DEVICE NAME               | String, 100 chars max
TEMPERATURE SCALE         | 1 Byte
OUTPUT 1 FUNCTION         | 1 Byte
OUTPUT 1 TRIGGER (SENSOR) | 1 Byte
OUTPUT 1 SETPOINT         | Float
OUTPUT 1 COMPRESSOR DELAY | Float
OUTPUT 2 FUNCTION         | 1 Byte
OUTPUT 2 TRIGGER (SENSOR) | 1 Byte
OUTPUT 2 SETPOINT         | Float
OUTPUT 2 COMPRESSOR DELAY | Float
```

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
    |             Device Responds with ACK on Success          |
    |<--------------------------------------------------------+|
    |                      Data: { ACK }                       |
    |                                                          |
    |                                                          |
    |        Device Responds with NACK & Error Code on Error   |
    |<--------------------------------------------------------+|
    |                 Data: { NACK, error code }               |
    |                                                          |
    |                                                          |
```

### Profile Packet

```
| AUTHENTICATION TOKEN | DEVICE ID | TIMESTAMP |  TEMPERATURE PROFILE  |
|       20 Bytes       | 128 Bytes |   Float   |    Variable Length    |
```

### Temperature Profile Data
```
PROFILE NAME LENGTH     | 1 Byte
PROFILE NAME            | String, 100 chars max
PROFILE TYPE            | 1 Byte
NUMBER OF POINTS        | 64 Bytes
POINT 1 OFFSET          | 64 Bytes
POINT 1 TRANSITION TYPE | 1 Byte
POINT 1 TEMPERATURE     | Float
...
POINT N OFFSET          | 64 Bytes
POINT N TRANSITION TYPE | 1 Byte
POINT N TEMPERATURE     | Float
```

# Error Codes






















