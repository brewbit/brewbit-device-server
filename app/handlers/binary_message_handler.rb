require 'message'
require 'api_message'
require 'binary_message_builder'
require 'model_t_responder'

class BinaryMessageHandler

  attr_reader :responder

  def initialize
    @responder = ModelTResponder.new
  end

  def process( message, device = nil )
    response = ''

    case message.message_type
    when Message::MESSAGE_TYPES[:api_version]
      response = process_api_version_message message
    when Message::MESSAGE_TYPES[:activation_token_request]
      response = process_activation_token_request
    when Message::MESSAGE_TYPES[:authentication_token_request]
      response = process_authentication_token_request message
    when Message::MESSAGE_TYPES[:device_status]
      response = process_device_status message
    when Message::MESSAGE_TYPES[:device_settings]
      response = process_device_settings message
    end

    response
  end

  private

  def process_api_version_message( message )
    api_message = ApiMessage.new
    api_message.read message.data
    result = api_message.process
    @responder.api_version = api_message.api_version
    @responder.device_id = api_message.device_id

    BinaryMessageBuilder.build Message::MESSAGE_TYPES[:response], result
  end

  def process_activation_token_request
    @activation_token = @responder.get_activation_token
    BinaryMessageBuilder.build Message::MESSAGE_TYPES[:activation_token_response], @activation_token
  end

  def process_authentication_token_request( message )
    token = @responder.get_authentication_token( @activation_token )
    BinaryMessageBuilder.build Message::MESSAGE_TYPES[:authentication_token_response], result
  end

  def process_device_status( message )
    # TODO: Upload the device status info to the server
    BinaryMessageBuilder.build Message::MESSAGE_TYPES[:response], Message::ERROR_CODES[:success]
  end

  def process_device_settings( message )
    # TODO: Upload the device settings info to the server
    BinaryMessageBuilder.build Message::MESSAGE_TYPES[:response], Message::ERROR_CODES[:success]
  end
end

