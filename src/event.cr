#
# Enet's event class
#

require "./peer"

macro event_type_query(name)
  def {{name.id}}?
    event_type == {{name}}
  end
end

module Enet
  class Event
    def initialize(event_ptr : LibEnet::Event*)
      @event = event_ptr

      raise NullPointerError.new if @event.null?
    end

    def peer : (Peer | Nil)
      Peer.new @event.value.peer unless @event.value.peer.null?
    end

    def channel_id
      @event.value.channel_id
    end

    def code
      @event.value.data
    end

    def event_type
      case @event.value.type
      when LibEnet::EventType::None
        :none
      when LibEnet::EventType::Connect
        :connect
      when LibEnet::EventType::Disconnect
        :disconnect
      when LibEnet::EventType::Receive
        :receive
      end
    end

    def to_s
      "Event##{event_type}:#{channel_id}:#{code}"
    end

    event_type_query :none
    event_type_query :connect
    event_type_query :disconnect
    event_type_query :receive
  end
end
