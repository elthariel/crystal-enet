require "../src/enet"

if ARGV.size != 1
  puts "usage ./client host:port"
  exit 42
end

Enet.init
puts "Running Enet version: #{Enet.version}"
addr = Enet::Address.new ARGV[0]
client = Enet::Host.new
peer = client.connect addr
if peer.nil?
  puts "Unable to connect"
  exit 21
end
run = true
while run
  peer.channel(0_u8).send "Message !"
  client.flush
  client.service do |event|
    puts "Received event : #{event.to_s}"
  end
end
Enet.deinit
