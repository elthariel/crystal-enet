#
# Address class
#

module Enet
  class Address
    def initialize(host : String, port : UInt16)
      @addr = LibEnet::Address.new

      self.ip = host
      self.port = port
    end

    def initialize(host_and_port : String)
      @addr = LibEnet::Address.new

      split = host_and_port.split(":")
      raise "Use host:port format when creating an Address" if split.size != 2

      self.ip = split[0]
      self.port = split[1].to_u16

      puts "New address: #{to_s}"
    end

    def initialize(other : LibEnet::Address)
      @addr = other
    end

    def port
      @addr.port
    end

    def port=(value)
      @addr.port = value
    end

    def ip
      net_ip = @addr.host.dup
      bytes = pointerof(net_ip).as(UInt8*).to_slice(4)
      bytes.join(".")
    end

    def ip=(value : String)
      LibEnet.enet_address_set_host(pointerof(@addr), value.to_unsafe)
    end

    def to_s
      "#{ip}:#{port}"
    end

    def to_unsafe
      pointerof(@addr)
    end
  end
end
