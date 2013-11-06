

##### Table of Contents

* [Server](#server)
  * [The What](#the_what)
  * [The How](#the_how)
* [Message Format](#message_format)
* [Device API](#device_api)
  * [API Version](#api_version)
  * [Response](#response)
  * [Activation Token Request](#activation_token_request)
  * [Activation Token Reply](#activation_token_reply)
  * [Authentication Token Request](#authentication_token_request)
  * [Authentication Token Reply](#authentication_token_reply)
  * [Authentication Request](#authentication_request)
  * [Device Status](#device_status)
  * [Device Settings](#device_settings)
  * [Temperature Profiles](#temp_profiles)
  * [Upgrade](#upgrade)
  * [Sample Flows](#sample_flows)
    * [Device Activation](#device_activation)
    * [Device Reconnect](#device_reconnect)
* [JSON API](#json_api)
* [Development](#development)

<a name='server'></a>
# Server

<a name='the_what'></a>
## The What
Device server that acts as an API translation layer between raw TCP
socket binary protocol for devices and JSON API for the Rails app.

<a name='the_how'></a>
## The How
Configurtion is in `config.rb`

Settings are:

  * HOST - Host IP to listen on
  * DEVICE\_PORT - Port that devices should connect on
  * WEB\_PORT - Port that accepts web calls for REST API
  * ENDIAN - Endianness of the binary protocol

<a name='device_api'></a>
# Device API

```
| START_MESSAGE | MESSAGE_TYPE | DATA_LENGTH |   DATA   |   CRC   |
|      U24      |       U8     |      U32    | Variable |   U16   |
```

## Message Types

### Summary

```
RESPONSE                      | 0
API VERSION                   | 1
ACTIVATION TOKEN REQUEST      | 2
ACTIVATION TOKEN RESPONSE     | 3
AUTHENTICATION TOKEN REQUEST  | 4
AUTHENTICATION TOKEN RESPONSE | 5
AUTHENTICATION REQUEST        | 6
DEVICE STATUS                 | 7
DEVICE SETTINGS               | 8
TEMPERATURE PROFILE           | 9
UPGRADE                       | 10
```

<a name='api_version'></a>
### API Version Message

Device specifies which API version it supports

#### Packet Contents

```
| API VERSION | DEVICE ID | FIRMWARE VERSION | WIFI FIRMWARE VERSION |
|      U8     |    U64    |      :TODO:      |        :TODO:         |
```

#### Expected Response(s)

  * If the API version is supported by the server, a `RESPONSE` packet with `SUCCESS` value is sent back
  * If the API version is not supported, a `RESPONSE` packet with `API VERSION NOT SUPPORTED` value is sent back

<a name='response'></a>
### Response Message

Response packet with response code for general messages

#### Packet Contents

```
| RESPONSE CODE |
|      U32      |
```

#### Response Codes

```
SUCCESS                     | 0
ACTIVATION TOKEN NOT FOUND  | 1
CRC FAILED                  | 2
API VERSION NOT SUPPORTED   | 3
DEVICE NOT FOUND            | 4
BAD AUTHENTICATION TOKEN    | 5
ACTIVATION TOKEN EXPIRED    | 6
BAD ACTIVATION TOKEN        | 7
AUTHENTICATION SUCCESSFUL   | 8
```

<a name='activation_token_request'></a>
### Activation Token Request Message

The device requests an activation token from the server.  The token expires after a short period.

#### Packet Contents

```
No data is needed, send empty packet
```

#### Expected Response(s)

An `ACTIVATION TOKEN RESPONSE` is sent back with the activation token.  The token will expire after a short time.

<a name='activation_token_response'></a>
### Activation Token Response Message

Server responds with the activation token to be used by the device.  Token expires after a short time.

#### Packet Contents
```
| ACTIVATION TOKEN |
|       U48        |
```

#### Expected Response(s)

No response is expected from the device.

<a name='authentication_token_request'></a>
### Authentication Token Request Message
The device requests the authentication token from the server.

#### Packet Contents
```
| ACTIVATION TOKEN |
|       U48        |
```

#### Expected Response(s)

  * If the activation token is found and it matches the device, the server responds with `AUTHENTICATION TOKEN RESPONSE` message containing the activation token.
  * If the activation token is not found, the server responds with `RESPONSE` message with `BAD ACTIVATION TOKEN`, the device is expected to restart the activation flow

<a name='authentication_token_response'></a>
### Authentication Token Response Message

The server responds to a successful request with the user's API key

#### Packet Contents
```
| AUTHENTICATION TOKEN |
|        U160          |
```

#### Expected Response(s)

The server does not expect a response from the device


<a name='authentication_request'></a>
### Authentication Request Message

A device authenticates with the server, with the API key it already has

#### Packet Contents
```
| AUTHENTICATION TOKEN |
|        U160          |
```

#### Expected Response(s)

  * If the authentication token is valid, the server sends back a `RESPONSE` message with `AUTHENTICATION SUCCESSFUL`
  * If the authentication token is not valid, the server sends back a `RESPONSE` message with `BAD AUTHENTICATION TOKEN`

<a name='device_status'></a>
### Device Status Message

This message is sent at a regular interval to the server from the device.  The device updates the server with it's status information, including probe readings.

#### Packet

```
| TIMESTAMP |   STATUS DATA   |
|    U32    | Variable Length |
```

#### Status Info

```
WIFI STRENGTH               | U32 (Scaled Integer, 100 factor)
NUMBER OF PROBES            | U32
PROBE TEMPERATURE VALUE 1   | U32 (Scaled Integer, 100 factor)
...
PROBE TEMPERATURE VALUE N   | U32 (Scaled Integer, 100 factor)
```

#### Expected Response(s)

Server sends back a `RESPONSE` message with `SUCCESS`.

<a name='device_settings'></a>
### Device Settings Message

This message is used by both, Device and Server, to update the current settings.
If there are changes made on the device, it updates the server with it's current status.
If the changes are made on the website, the device is updated with the latest changes.
The message with the latest timestamp wins, if there are conflicts.

#### Packet

```
| TIMESTAMP |  SETTINGS DATA  |
|    U32    | Variable Length |
```

#### Settings data

```
DEVICE NAME LENGTH        | U8
DEVICE NAME               | String, 100 chars max
TEMPERATURE SCALE         | U8
OUTPUTS NUMBER            | U32
OUTPUT 1 FUNCTION         | U8
OUTPUT 1 TRIGGER (SENSOR) | U8
OUTPUT 1 SETPOINT         | U32 (Scaled Integer, 100 factor)
OUTPUT 1 COMPRESSOR DELAY | U32 (Scaled Integer, 100 factor)
...
OUTPUT N FUNCTION         | U8
OUTPUT N TRIGGER (SENSOR) | U8
OUTPUT N SETPOINT         | U32 (Scaled Integer, 100 factor)
OUTPUT N COMPRESSOR DELAY | U32 (Scaled Integer, 100 factor)
```

#### Expected Response(s)

  * The device is the originator, the server will respond with `RESPONSE` message, with the appropriate code
  * When the server is the originator, no response is expected from the device

<a name='temp_profiles'></a>
### Temperature Profiles Message

Sending temperature profiles to the device

#### Packet Contents

```
| TIMESTAMP |  TEMPERATURE PROFILE  |
|    U32    |    Variable Length    |
```

#### Temperature Profile Data
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

#### Expected Response(s)

<a name='upgrade'></a>
### Upgrade Message

Sends the device new version of firmware to install

#### Packet Contents

```
:TODO:
```

#### Expected Response(s)

:TODO:

<a name='sample_flows'></a>
## Sample Flows

<a name='device_activation'></a>
### Device Activation

This shows the messages that are sent across for device activation.

```
  Device                                                 Device Server
    +                                                          +
    |                                                          |
    |               Device Opens a raw TCP socket              |
    |+-------------------------------------------------------->|
    |                                                          |
    |             Device Sends API VERSION MESSAGE             |
    |+-------------------------------------------------------->|
    |                                                          |
    |               Server Sends RESPONSE Message              |
    |<--------------------------------------------------------+|
    |                                                          |
    |           Device Sends ACTIVATION TOKEN REQUEST          |
    |+-------------------------------------------------------->|
    |                                                          |
    |           Server Sends ACTIVATION TOKEN RESPONSE         |
    |<--------------------------------------------------------+|
    |                                                          |
    |******** User Enters Activation Token On Website *********|
    |                                                          |
    |                                                          |
    |         Device Sends AUTHENTICATION TOKEN REQUEST        |
    |+-------------------------------------------------------->|
    |                                                          |
    |         Server Sends AUTHENTICATION TOKEN REPLY          |
    |<--------------------------------------------------------+|
    |                                                          |
```


<a name='device_reconnect'></a>
### Device Re-Connect

This shows the messages that are sent when an activated device re-connects to the server


```
  Device                                                 Device Server
    +                                                          +
    |                                                          |
    |               Device Opens a raw TCP socket              |
    |+-------------------------------------------------------->|
    |                                                          |
    |             Device Sends API VERSION MESSAGE             |
    |+-------------------------------------------------------->|
    |                                                          |
    |               Server Sends RESPONSE Message              |
    |<--------------------------------------------------------+|
    |                                                          |
    |         Device Sends AUTHENTICATION TOKEN REQUEST        |
    |+-------------------------------------------------------->|
    |                                                          |
    |         Server Sends AUTHENTICATION TOKEN REPLY          |
    |<--------------------------------------------------------+|
    |                                                          |
```

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

