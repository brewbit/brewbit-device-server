require 'json'
require 'message'

class BinaryMessageBuilder

  def self.build( type, data )
    case type
    when Message::MESSAGE_TYPES[:response]
      message = build_response_message data
    when Message::MESSAGE_TYPES[:activation_token_response]
      message = build_activation_token_message data
    when Message::MESSAGE_TYPES[:authentication_token_response]
      message = build_authenticatoin_token_response_message data
    end

    message
  end

  private

  def self.build_response_message( data )
    self.build_message Message::MESSAGE_TYPES[:response], data
  end

  def self.build_activation_token_message( data )
    self.build_message Message::MESSAGE_TYPES[:activation_token_response], data
  end

  def self.build_authenticatoin_token_response_message( data )
    self.build_message Message::MESSAGE_TYPES[:authentication_token_response], data
  end

  def self.build_message( type, data )
    message = Message.new
    message.message_type = type
    message.data_length = "#{data}".length
    message.data = "#{data}"
    message.build_crc

    message
  end
end

