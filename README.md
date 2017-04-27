# Crystal binding of the ENet networking library

ENet's purpose is to provide a relatively thin, simple and robust network communication layer on top of UDP (User Datagram Protocol).The primary feature it provides is optional reliable, in-order delivery of packets.

See Enet's documentation here: http://enet.bespin.org/index.html

## Dependencies

  - libenet
  - pkg-config

### Install dependencies on Debian

`apt-get install -y libenet pkg-config`

### Install dependencies on OSX

`brew install libenet pkg-config`

## Run samples

  - `crystal samples/server.cr`
  - `crystal samples/client localhost:42042`
