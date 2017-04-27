#
# High level wrapper around the Host class providing a main loop
#

require "./host"

module Enet
  abstract class HostServiceLoop
    @running = false

    def initialize(bind_addr : String?,
                   max_peers : UInt32,
                   max_chans : UInt32,
                   down_bw : UInt32,
                   up_bw : UInt32)
      if bind_addr.nil?
        addr = nil
      else
        addr = Address.new bind_addr
      end
      @host = Host.new(addr, max_peers, max_chans, down_bw, up_bw)
    end

    def running?
      @running
    end

    def stop
      @running = false
    end

    def timeout
      500
    end

    def run
      @running = true

      puts "ENet main loop starting..."

      while @running
        @host.service(timeout) do |event|
          peer = event.peer

          on_event(event)
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

    # Called for every event (event the :none event)
    abstract def on_event(event)
    abstract def on_connect(event)
    abstract def on_disconnect(event)
    abstract def on_receive(event)
    abstract def on_none(event)
  end
end
