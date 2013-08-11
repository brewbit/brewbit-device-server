require 'message'
require 'data_validator'
require 'message_builder'
require 'message_handler'

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

    message = Message.new
    message.read data

    puts "Received message: #{message.inspect}"

    if DataValidator.valid? data
      @handler = MessageHandler.new
      response_message = @handler.process message
    else
      response_message = MessageBuilder.build Message::MESSAGE_TYPES[:nack]
    end

    send_message response_message unless response_message == false
  end

  def self.devices
    @@connected_devices
  end

  def send_message( message )
    puts "Sending Message to device: #{message.inspect}"

    send_data message.to_binary_s
  end
end

