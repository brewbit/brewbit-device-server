require 'message'
require 'temperature_data'
require 'json'
require 'httparty'

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
    # TODO check version matches

    temp_data = TemperatureData.new
    temp_info = temp_data.read data
    puts "Sending to BrewBit.com: temperature - #{temp_info}"

    probe_type = temp_data.probe == 1 ? "one" : "two"

    b = {
      device_id: "e52025ca044067a862c7ff79293b10830ee0dec5",
      probe: probe_type,
      value: temp_data.temperature.round(2),
      auth_token: "TyfyJUjJSm6PdB9xGbsk"
    }.to_json

    puts "Body: #{b.inspect}"

    response = HTTParty.post 'http://brewbit.herokuapp.com/api/v1/temperatures',
                             body: b,
                             headers: { 'Content-Type' => 'application/json' }

    puts "Response: #{response.inspect}"

    MessageBuilder.build Message::MESSAGE_TYPES[:ack]
  end
end

