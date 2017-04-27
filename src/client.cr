#
# High-level ENet client class. Subclass your own
#

require "./host_service_loop"

module Enet
  class Client < HostServiceLoop
    alias State = LibEnet::PeerState

    @peer = uninitialized Peer
    @connected = false

    def initialize(address : String,
                   peers : UInt32 = 32_u32,
                   channels : UInt32 = 32_u32,
                   down_bw : UInt32 = 64_u32 * 1024 / 8,
                   up_bw : UInt32 = 16_u32 * 1024 / 8)
      super nil, peers, channels, down_bw, up_bw

      addr = Address.new(address)
      peer = @host.connect(addr, channels.to_u64)
      if peer.nil?
        raise NullPointerError.new "Host.connect"
      else
        @peer = peer
      end
    end

    def connected?
      @connected
    end

    def on_event(event)
    end

    def on_connect(event)
      puts "Enet::Client: Connection established."
      @connected = true
    end

    def on_disconnect(event)
      puts "Enet::Client: Connection closed."
      @connected = false
    end

    def on_receive(event)
      puts "Received data from server. Handle it by overriding #on_receive"
    end

    def on_none(event)
    end

    def channel(id)
      @peer.channel(id)
    end
  end
end
