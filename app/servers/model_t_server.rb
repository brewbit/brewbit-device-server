require 'message'
require 'binary_message_builder'
require 'binary_message_handler'

class ModelTServer < EM::Connection

  @@connected_devices = Array.new

  def post_init
    #puts 'device connected'
    @@connected_devices.push self
    @handler = BinaryMessageHandler.new
    @message = Message.new
  end

  def unbind
    @@connected_devices.delete self
    #puts 'device disconnected'
  end

  def receive_data( data )
    response_message = false

    @message.read data

    if @message.valid?
      response_message = @handler.process message, self
    else
      response_message = failed_crc_message
    end

    send_message response_message unless response_message == false
  end

  def self.devices
    @@connected_devices
  end

  private

  def send_message( message )
    send_data message.to_binary_s
  end

  def failed_crc_message
    BinaryMessageBuilder.build Message::MESSAGE_TYPES[:ack], Message::ERROR_CODES[:crc_failed]
  end
end

