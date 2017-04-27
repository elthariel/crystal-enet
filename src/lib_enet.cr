@[Link("enet")]
lib LibEnet
  # Configuration constants
  HOST_RECEIVE_BUFFER_SIZE          = 256 * 1024
  HOST_SEND_BUFFER_SIZE             = 256 * 1024
  HOST_BANDWIDTH_THROTTLE_INTERVAL  = 1000
  HOST_DEFAULT_MTU                  = 1400
  HOST_DEFAULT_MAXIMUM_PACKET_SIZE  = 32 * 1024 * 1024
  HOST_DEFAULT_MAXIMUM_WAITING_DATA = 32 * 1024 * 1024

  PEER_DEFAULT_ROUND_TRIP_TIME       =  500
  PEER_DEFAULT_PACKET_THROTTLE       =   32
  PEER_PACKET_THROTTLE_SCALE         =   32
  PEER_PACKET_THROTTLE_COUNTER       =    7
  PEER_PACKET_THROTTLE_ACCELERATION  =    2
  PEER_PACKET_THROTTLE_DECELERATION  =    2
  PEER_PACKET_THROTTLE_INTERVAL      = 5000
  PEER_PACKET_LOSS_SCALE             = (1 << 16)
  PEER_PACKET_LOSS_INTERVAL          = 10000
  PEER_WINDOW_SIZE_SCALE             = 64 * 1024
  PEER_TIMEOUT_LIMIT                 =    32
  PEER_TIMEOUT_MINIMUM               =  5000
  PEER_TIMEOUT_MAXIMUM               = 30000
  PEER_PING_INTERVAL                 =   500
  PEER_UNSEQUENCED_WINDOWS           =    64
  PEER_UNSEQUENCED_WINDOW_SIZE       =  1024
  PEER_UNSEQUENCED_WINDOW_SIZE_DIV32 = PEER_UNSEQUENCED_WINDOW_SIZE / 32
  PEER_FREE_UNSEQUENCED_WINDOWS      =     32
  PEER_RELIABLE_WINDOWS              =     16
  PEER_RELIABLE_WINDOW_SIZE          = 0x1000
  PEER_FREE_RELIABLE_WINDOWS         =      8

  # Enums
  enum EventType
    None
    Connect
    Disconnect
    Receive
  end

  enum PeerState
    Disconnected
    Connecting
    AckConnect
    ConnectionPending
    ConnectionSucceeded
    Connected
    DisconnectLater
    Disconnecting
    AckDisconnect
    Zombie
  end

  @[Flags]
  enum PacketFlag : UInt32
    Reliable           = 1 << 0
    Unsequenced        = 1 << 1
    NoAllocate         = 1 << 2
    UnreliableFragment = 1 << 3
    Sent               = 1 << 8
  end

  # Opaque types
  type List = Pointer(Void)
  type Host = Void

  # Structs
  struct ListNode
    next : Pointer(Void)
    prev : Pointer(Void)
  end

  struct Address
    host : UInt32
    port : UInt16
  end

  struct Channel
    out_reliable_seq : UInt16
    out_unreliable_seq : UInt16
    used_reliable_windows : UInt16
    reliable_windows : UInt16[PEER_RELIABLE_WINDOWS]
    in_reliable_seq : UInt16
    in_unreliable_seq : UInt16
    in_reliable_cmds : List
    in_unreliable_cmds : List
  end

  struct Peer
    dispatch_list : ListNode
    host : Pointer(Host)
    out_peer_id : UInt16
    in_peer_id : UInt16
    connect_id : UInt32
    out_session_id : UInt8
    in_session_id : UInt8
    address : Address
    data : Pointer(Void)
    state : PeerState
    channels : Pointer(Channel)
    channel_count : LibC::SizeT
    in_bandwidth : UInt32
    out_bandwidth : UInt32
    in_bandwidth_throttle_epoch : UInt32
    out_bandwidth_throttle_epoch : UInt32
    in_data_total : UInt32
    out_data_total : UInt32
    last_send_time : UInt32
    last_receive_time : UInt32
    next_timeout : UInt32
    earliest_timeout : UInt32
    packet_loss_epoch : UInt32
    packets_sent : UInt32
    packets_lost : UInt32
    packet_loss : UInt32
    packate_loss_variance : UInt32
    packet_throttle : UInt32
    packet_throttle_limit : UInt32
    packet_throttle_counter : UInt32
    packet_throttle_epoch : UInt32
    packet_throttle_acceleration : UInt32
    packet_throttle_decelaration : UInt32
    packet_throttle_interval : UInt32
    ping_interval : UInt32
    timeout_limit : UInt32
    timeout_min : UInt32
    timeout_max : UInt32
    last_rtt : UInt32
    lowest_rtt : UInt32
    last_rtt_variance : UInt32
    highest_rtt_variance : UInt32
    rtt : UInt32
    rtt_variance : UInt32
    mtu : UInt32
    window_size : UInt32
    reliable_data_in_transit : UInt32
    out_reliable_seq : UInt16
    acks : List
    sent_reliable_cmds : List
    sent_unreliable_cmds : List
    out_reliable_cmds : List
    out_unreliable_cmds : List
    dispatched_cmds : List
    needs_dispatch : Int32
    in_unseq_group : UInt16
    out_unseq_group : UInt16
    unseq_window : UInt32[PEER_UNSEQUENCED_WINDOW_SIZE_DIV32]
    event_data : UInt32
    total_waiting_data : LibC::SizeT
  end

  struct Packet
    data : Pointer(UInt8)
    size : LibC::SizeT
    flags : UInt32
    free_callback : Pointer(Void) -> Void
    reference_count : LibC::SizeT
    user_data : Pointer(Void)
  end

  struct Event
    type : EventType
    peer : Pointer(Peer)
    channel_id : UInt8
    data : UInt32
    packet : Pointer(Packet)
  end

  struct Buffer
    data : Pointer(Void)
    data_length : LibC::SizeT
  end

  HOST_ANY       =          0
  HOST_BROADCAST = 0xFFFFFFFF
  PORT_ANY       =          0

  # Global functions
  fun enet_initialize : Int32
  fun enet_deinitialize : Void
  fun enet_linked_version : UInt32

  # Address functions
  fun enet_address_get_host(Address*, LibC::Char*, LibC::SizeT) : Int32
  fun enet_address_get_host_ip(Address*, LibC::Char*, LibC::SizeT) : Int32
  fun enet_address_set_host(Address*, LibC::Char*) : Int32

  # Host functions
  fun enet_host_create(Address*, LibC::SizeT, LibC::SizeT, UInt32, UInt32) : Host*
  fun enet_host_destroy(Host*) : Void
  fun enet_host_flush(Host*) : Void
  fun enet_host_service(Host*, Event*, UInt32) : Int32
  fun enet_host_connect(Host*, Address*, LibC::SizeT, UInt32) : Pointer(Peer)
  fun enet_host_bandwidth_limit(Host*, UInt32, UInt32)
  fun enet_host_bandwidth_throttle(Host*)
  fun enet_host_broadcast(Host*, UInt8, Packet*)
  fun enet_host_channel_limit(Host*, LibC::SizeT)
  fun enet_host_check_events(Host*, Event*) : Int32

  # Peer functions
  fun enet_peer_send(Peer*, UInt8, Packet*) : Int32
  fun enet_peer_receive(Peer*, UInt8) : Pointer(Packet)
  fun enet_peer_ping(Peer*)
  fun enet_peer_ping_interval(Peer*, UInt32)
  fun enet_peer_timeout(Peer*, UInt32, UInt32, UInt32)
  fun enet_peer_reset(Peer*)
  fun enet_peer_reset_queues(Peer*)
  fun enet_peer_disconnect(Peer*, UInt32)
  fun enet_peer_disconnect_later(Peer*, UInt32)
  fun enet_peer_disconnect_now(Peer*, UInt32)
  fun enet_peer_throttle(Peer*, UInt32) : Int32

  # Packet functions
  fun enet_crc32(Buffer*, LibC::SizeT) : UInt32
  fun enet_packet_create(Void*, LibC::SizeT, UInt32) : Pointer(Packet)
  fun enet_packet_destroy(Packet*)
  fun enet_packet_resize(Packet*, LibC::SizeT) : Int32
end
