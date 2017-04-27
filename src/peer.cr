#
# The Peer class
#

require "./channel"

module Enet
  class Peer
    def initialize(peer_ptr : LibEnet::Peer*)
      @peer = peer_ptr
      raise Enet::NullPointerError.new if @peer.null?
    end

    #
    # Library functions calls
    #
    def ping
      LibEnet.enet_peer_ping(@peer)
    end

    def ping_interval(interval)
      LibEnet.enet_peer_ping_interval(@peer, interval)
    end

    def timeout(limit, min, max)
      LibEnet.enet_peer_timeout(@peer, limit, min, max)
    end

    def disconnect(code)
      LibEnet.enet_peer_disconnect(@peer, code)
    end

    def disconnect_later(code)
      LibEnet.enet_peer_disconnect_later(@peer, code)
    end

    def disconnect_now(code)
      LibEnet.enet_peer_disconnect_now(@peer, code)
    end

    def reset!
      LibEnet.enet_peer_reset(@peer)
    end

    def channel(id : UInt8 = 0)
      Channel.new(self, id)
    end

    #
    # Accessors
    #
    def address
      Address.new(@peer.value.address)
    end

    def state
      case @peer.value.state
      when LibEnet::PeerState::Disconnected
        :disconnected
      when LibEnet::PeerState::Connecting
        :connecting
      when LibEnet::PeerState::AckConnect
        :ack_connect
      when LibEnet::PeerState::ConnectionPending
        :connection_pending
      when LibEnet::PeerState::ConnectionSucceeded
        :connection_succeeded
      when LibEnet::PeerState::Connected
        :connected
      when LibEnet::PeerState::DisconnectLater
        :disconnect_later
      when LibEnet::PeerState::AckDisconnect
        :ack_disconnect
      when LibEnet::PeerState::Zombie
        :zombie
      end
    end

    def to_s
      "Peer:#{address.to_s}:#{state}"
    end

    def hexdump
      bytes = @peer.as(UInt8*).to_slice(sizeof(typeof(LibEnet::Peer)))
      bytes.hexdump
    end

    def to_unsafe
      @peer
    end
  end
end
