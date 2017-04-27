#
# ENet's Packet class
#

module Enet
  class Packet
    alias Flag = LibEnet::PacketFlag

    def initialize(ptr : Void*, size : LibC::SizeT,
                   flags : UInt32 = Flag::Reliable.value)
      @owned = true
      @packet = LibEnet.enet_packet_create(ptr, size, flags)

      raise NullPointerError.new if @packet.null?
    end

    def initialize(bytes : Bytes, flags : UInt32 = Flag::Reliable.value)
      initialize(bytes.to_unsafe.as(Void*), bytes.size.to_u64, flags)
    end

    def initialize(str : String, flags : UInt32 = Flag::Reliable.value)
      initialize(str.to_slice, flags)
    end

    def initialize(packet : LibEnet::Packet*, owned = true)
      @owned = owned
      @packet = packet
      raise NullPointerError.new if @packet.null?
    end

    def finalize
      LibEnet.enet_packet_destroy(@packet) if @owned
    end

    def size
      @packet.value.size
    end

    def bytes
      Bytes.new(@packet.value.data, @packet.value.size)
    end

    def flag_enable(flag)
      @packet.value.flags |= flag
    end

    def flag_disable(flag)
      @packet.value.flags &= flag
    end

    def owned?
      @owned
    end

    def own!
      @onwed = true
    end

    def disown!
      @owned = false
    end

    def to_unsafe
      @packet
    end
  end
end
