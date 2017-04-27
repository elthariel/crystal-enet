#
# High level server class
#

require "./host_service_loop"

macro event_handler(name)
  def on_{{name.id}}(event)
    puts "Received a {{name}} event. Override #on_{{name.id}} to handle it"
  end
end

module Enet
  class Server < HostServiceLoop
    def on_event(event)
    end

    def on_none(event)
      puts "No event received within #{timeout}ms (#on_none). Retrying..."
    end

    event_handler :connect
    event_handler :disconnect
    event_handler :receive
  end
end
