require 'message'

class MessageBuilder

  def self.build( type, data = '' )
    case type
    when Message::MESSAGE_TYPES[:ack]
      message = build_ack_message
    when Message::MESSAGE_TYPES[:nack]
      message = build_nack_message
    end

    message
  end

  private

  def self.build_ack_message
    message = Message.new
    message.message_type = Message::MESSAGE_TYPES[:ack]
    message.data_length = 0
    message.data = ''
    message.build_crc

    message
  end

  def self.build_nack_message
    message = Message.new
    message.message_type = Message::MESSAGE_TYPES[:nack]
    message.data_length = 0
    message.data = ''
    message.build_crc

    message
  end
end

