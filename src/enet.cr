#
# Main module for Enet
#

require "./lib_enet"
require "./address"
require "./packet"
require "./peer"
require "./host"
require "./server"

module Enet
  class Error < Exception
  end

  class FunctionError < Error
    def initialize(fun_name : String, msg : String = "error")
      super "#{fun_name}: #{msg}"
    end
  end

  class NullPointerError < Error
  end

  def self.init
    if LibEnet.enet_initialize != 0
      raise FunctionError.new("enet_initialize")
    end
  end

  def self.deinit
    LibEnet.enet_deinitialize
  end

  def self.version : String
    raw_version = LibEnet.enet_linked_version
    major = (raw_version & 0xFF0000) >> 16
    minor = (raw_version & 0xFF00) >> 8
    patch = raw_version & 0xFF

    "#{major}.#{minor}.#{patch}"
  end
end
