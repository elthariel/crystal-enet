#
# Enet's Host class. Mostly a big wrapper around a socket :)
#

require "./peer"
require "./event"

module Enet
  class Host
    def initialize(addr : Address? = nil,
                   peers : UInt32 = 32_u32,
                   channels : UInt32 = 32_u32,
                   down_bandwidth : UInt32 = 64_u32 * 1024 / 8,
                   up_bandwidth : UInt32 = 16_u32 * 1024 / 8)
      @addr = addr
      @peers = peers
      @channels = channels
      @down_bandwidth = down_bandwidth
      @up_bandwidth = up_bandwidth

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

      if result < 0
        return false
      elsif result > 0
        yield Enet::Event.new(pointerof(event))
      end
      true
    end

    def connect(address : Address,
                channels : LibC::SizeT = 32_u64,
                data : UInt32 = 0_u32)
      res = LibEnet.enet_host_connect(@host, address, channels, data)

      if res.null?
        nil
      else
        Peer.new res
      end
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
