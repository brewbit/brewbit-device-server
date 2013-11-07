require 'json'
require 'httparty'
require 'message'
require 'binary_message_builder'

class BinaryMessageHandler

  attr_reader :api_version

  SUPPORTED_API_VERSIONS = {
    one: "1"
  }

  def initialize
    @api_version = ''
  end

  def process( message, device = nil )
    response = ''

    case message.message_type
    when Message::MESSAGE_TYPES[:api_version]
      response = process_api_version_message message
    end

    response
  end

  private

  def process_api_version_message( message )
    api_version = message.data.to_binary_s
    response = ''

    if api_version_supported?( api_version )
      @api_version = api_version
      response = BinaryMessageBuilder.build Message::MESSAGE_TYPES[:ack], Message::ERROR_CODES[:success]
    else
      response = BinaryMessageBuilder.build Message::MESSAGE_TYPES[:ack], Message::ERROR_CODES[:api_version_not_supported]
    end

    response
  end

  def api_version_supported?( api_version )
    SUPPORTED_API_VERSIONS.has_value? api_version
  end
end

