#
# Represent a communication channel of a peer
#

module Enet
  class Channel
    def initialize(peer : Peer, channel : UInt8)
      @peer = peer
      @channel = channel
    end

    def send(*args)
      packet = Packet.new *args
      send packet
    end

    def send(packet : Packet)
      # Once a packet is sent, LibEnet own it and will free it
      packet.disown!

      # Send the packet
      LibEnet.enet_peer_send(@peer, @channel, packet) == 0
    end

    def receive
      packet = LibEnet.enet_peer_receive(@peer, @channel)

      Packet.new packet unless packet.null?
    end
  end
end
