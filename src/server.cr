#
# ENet Server. Subclass it for goodness
#

require "./host"

module Enet
  class Server
    @running = false

    def initialize(bind_addr : String,
                   max_peers : UInt32,
                   max_chans : UInt32,
                   down_bw : UInt32,
                   up_bw : UInt32)
      addr = Address.new bind_addr
      @host = Host.new(addr, max_peers, max_chans, down_bw, up_bw)
    end

    def running?
      @running
    end

    def stop
      @running = false
    end

    def run
      @running = true

      puts "Running server..."

      while @running
        @host.service(100) do |event|
          peer = event.peer
          unless peer.nil?
            puts peer.hexdump
          end

          case event.event_type
          when :connect
            on_connect(event)
          when :disconnect
            on_disconnect(event)
          when :receive
            on_receive(event)
          when :none
            on_none(event)
          end
        end
      end
    end

    def on_connect(event)
      puts "Connect event #{event}"
    end

    def on_disconnect(event)
      puts "Disconnect event #{event}"
    end

    def on_receive(event)
      puts "Receive event #{event}"
    end

    def on_none(event)
      puts "NONE EVENT : #{event}"
    end
  end
end
