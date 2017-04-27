#
# Enet's Host class. Mostly a big wrapper around a socket :)
#

require "./peer"
require "./event"

module Enet
  class Host
    def initialize(bind_addr : Address? = nil,
                   peers : UInt32 = 32_u32,
                   channels : UInt32 = 32_u32,
                   down_bandwidth : UInt32 = 64_u32 * 1024 / 8,
                   up_bandwidth : UInt32 = 16_u32 * 1024 / 8)
      @addr = bind_addr
      @peers = peers
      @channels = channels
      @down_bandwidth = down_bandwidth
      @up_bandwidth = up_bandwidth

      if bind_addr.nil?
        addr = Pointer(LibEnet::Address).null
      else
        addr = bind_addr.to_unsafe
      end
      @host = LibEnet.enet_host_create(addr, peers, channels,
        down_bandwidth, up_bandwidth)
      raise NullPointerError.new("enet_host_create") if @host.null?
    end

    def flush
      LibEnet.enet_host_flush(@host)
    end

    def service(timeout = 1000)
      result = LibEnet.enet_host_service(@host, out event, timeout)
      unless event.peer.null?
        # puts event.peer.value.inspect
      end

      yield Enet::Event.new(pointerof(event))
      result > 0
    end

    def connect(address : Address,
                channels : LibC::SizeT = 32_u64,
                data : UInt32 = 0_u32) : Peer
      res = LibEnet.enet_host_connect(@host, address, channels, data)

      raise NullPointerError.new("enet_host_connect") if res.null?
      Peer.new res
    end

    def finalize
      LibEnet.enet_host_destroy(@host)
      @host = Pointer(LibEnet::Host).null
    end

    def to_unsafe
      @host
    end
  end
end
