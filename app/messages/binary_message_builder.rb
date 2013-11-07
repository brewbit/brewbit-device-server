require 'json'
require 'message'

class BinaryMessageBuilder

  def self.build( type, data )
    case type
    when Message::MESSAGE_TYPES[:ack]
      message = build_ack_message data
    end

    message
  end

  private

  def self.build_ack_message( data )
    message = Message.new
    message.message_type = Message::MESSAGE_TYPES[:ack]
    message.data_length = data.to_s.length
    message.data = "#{data}"
    message.build_crc

    message
  end
end

