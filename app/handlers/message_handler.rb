require 'message'

class MessageHandler

  def initialize
    @version = ''
  end

  def process( message )
    result = ''

    case message.message_type
    when Message::MESSAGE_TYPES[:version]
      result = process_version message.data
    when Message::MESSAGE_TYPES[:temperature]
      result = process_temperature message.data
    else
      result = MessageBuilder.build Message::MESSAGE_TYPES[:nack]
    end

    result
  end

  def version
    @version
  end

  private

  def process_version( data )
    @version = data
    MessageBuilder.build Message::MESSAGE_TYPES[:ack]
  end

  def process_temperature( data )
    # Send data to server
    MessageBuilder.build Message::MESSAGE_TYPES[:ack]
  end
end

