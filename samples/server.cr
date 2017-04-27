require "../src/enet"

class MyServer < Enet::Server
  BANDWIDTH = 32_u32 * 1024

  def initialize
    super("0.0.0.0:42042", 32_u32, 32_u32, BANDWIDTH, BANDWIDTH)
  end

  def on_connect(event)
    puts "#{event.peer.to_s} connected"
  end

  def on_disconnected(event)
    puts "#{event.peer.to_s} connected"
  end

  def on_receive(event)
    puts "#{event.peer.to_s} received data"
  end
end

Enet.init
server = MyServer.new
server.run
Enet.deinit
