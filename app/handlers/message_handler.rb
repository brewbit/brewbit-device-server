require 'message'

class MessageHandler

  def initialize
    @version = ''
  end

  def process( message )
    result = ''

    case message.message_type
    when Message::MESSAGE_TYPES[:ack]
      result = false
    when Message::MESSAGE_TYPES[:nack]
      result = false
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

    # TODO Send data to server & get response
    puts "Sending to BrewBit.com: version - #{version}"

    MessageBuilder.build Message::MESSAGE_TYPES[:ack]
  end

  def process_temperature( data )
    # TODO Send data to server & get response
    temp_data = TemperatureData.new
    temp_info = temp_data.read data
    puts "Sending to BrewBit.com: temperature - #{temp_info}"

    MessageBuilder.build Message::MESSAGE_TYPES[:ack]
  end
end

