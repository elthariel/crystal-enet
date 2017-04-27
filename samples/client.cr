require "../src/enet"

if ARGV.size != 1
  puts "usage ./client host:port"
  exit 42
end

class MyClient < Enet::Client
  BANDWIDTH = 32_u32 * 1024

  def initialize(addr)
    super(addr, 32_u32, 32_u32, BANDWIDTH, BANDWIDTH)
  end

  # Calls when the receive call timesout, i.e. no event was received
  def on_none(event)
    if connected?
      puts "Sendind a ping..."
      channel(0_u8).send("Ping")
    end
  end

  def on_receive(event)
    puts "Received a pong"
  end
end

Enet.init
puts "Running Enet version: #{Enet.version}"
client = MyClient.new(ARGV[0])
client.run
Enet.deinit
