require 'json'
require 'message'
require 'temperature_profile_data'

class MessageBuilder

  def self.build( type, data = '' )
    case type
    when Message::MESSAGE_TYPES[:ack]
      message = build_ack_message
    when Message::MESSAGE_TYPES[:nack]
      message = build_nack_message
    when Message::MESSAGE_TYPES[:temp_profile]
      message = build_temp_profile_message data
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

  def self.build_temp_profile_message( data )
    result = process_temp_profile_data( data )

    message = Message.new
    message.message_type = Message::MESSAGE_TYPES[:temp_profile]
    message.data = result
    message.data_length = result.size
    message.build_crc

    message
  end

  def self.process_temp_profile_data( data )
    profile = TemperatureProfileData.new

    json_data = JSON.parse data

    profile.name_length       = json_data['name'].size
    profile.name              = json_data['name']
    profile.number_of_points  = json_data['temperature_points'].size

    json_data['temperature_points'].each do |point|
      profile.points << {
        point_index: point['index'],
        duration: point['duration'],
        transition: TemperatureProfileData::TRANSITION_TYPE[point['transition'].to_sym],
        temperature: point['temperature']
      }
    end

    profile.to_binary_s
  end
end

