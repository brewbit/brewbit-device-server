require 'binary_message_handler'

class ModelTServer < EM::Connection

  @@connected_devices = Array.new

  attr_accessor :api_version, :id, :authentication_token

  def post_init
    @@connected_devices.push self
    #@handler = BinaryMessageHandler.new self
  end

  def unbind
    @@connected_devices.delete self
  end

  def receive_data( data )
    #send_message @handler.process data
  end

  def self.devices
    @@connected_devices
  end

  private

  def send_message( message )
    send_data message
  end
end

