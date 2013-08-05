require 'message'
require 'data_validator'
require 'message_builder'

class ModelTServer < EM::Connection

  @@connected_devices = Array.new

  def post_init
    puts 'device connected'
    @@connected_devices.push self
  end

  def unbind
    @@connected_devices.delete self
    puts 'device disconnected'
  end

  def receive_data( data )
    response_message = ''

    if DataValidator.valid? data
      message = Message.new
      message.read data

      @handler = MessageHandler.new message
      response_message = @handler.process
    else
      response_message = MessageBuilder.build Message::MESSAGE_TYPES[:nack]
    end

    send_message response_message
  end

  def self.devices
    @@connected_devices
  end

  def send_message( message )
    send_data message.to_binary_s
  end
end

