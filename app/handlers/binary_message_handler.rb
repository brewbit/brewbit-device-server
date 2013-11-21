require 'message'
require 'api_message'
require 'binary_message_builder'
require 'model_t_responder'
require 'authentication_token_request_message'
require 'device_status_message'
require 'device_settings_message'

class BinaryMessageHandler

  def initialize( device )
    @device = device
    @responder = ModelTResponder.new( @device )
  end

  def process( data )
    message = nil

    begin
      message = Message.read( data )
    rescue => e
      puts e
      return BinaryMessageBuilder.build_failed_crc_message
    end

    return BinaryMessageBuilder.build_failed_crc_message unless message.valid?

    case message.message_type
    when Message::MESSAGE_TYPES[:api_version]
      return process_api_version_message message
    when Message::MESSAGE_TYPES[:activation_token_request]
      return process_activation_token_request
    when Message::MESSAGE_TYPES[:authentication_token_request]
      return process_authentication_token_request message
    when Message::MESSAGE_TYPES[:device_status]
      return process_device_status message
    when Message::MESSAGE_TYPES[:device_settings]
      return process_device_settings message
    when Message::MESSAGE_TYPES[:authentication_request]
      return process_authentication_request message
    end
  end

  private

  def process_api_version_message( message )
    api_message = ApiMessage.read message.data
    result = api_message.process
    @device.api_version = api_message.api_version
    @device.id = api_message.device_id

    BinaryMessageBuilder.build Message::MESSAGE_TYPES[:response], result
  end

  def process_activation_token_request
    begin
      activation_token = @responder.get_activation_token
    rescue ModelTResponder::FailedToGetActivationToken
      return BinaryMessageBuilder.build Message::MESSAGE_TYPES[:response], Message::ERROR_CODES[:failed_to_get_activation_token]
    end

    BinaryMessageBuilder.build Message::MESSAGE_TYPES[:activation_token_response], activation_token
  end

  def process_authentication_token_request( message )
    auth_message = AuthenticationTokenRequestMessage.read message.data

    begin
      @authentication_token = @responder.get_authentication_token( auth_message.activation_token )
    rescue ModelTResponder::ActivationTokenNotFound
      return BinaryMessageBuilder.build Message::MESSAGE_TYPES[:response], Message::ERROR_CODES[:activation_token_not_found]
    end

    BinaryMessageBuilder.build Message::MESSAGE_TYPES[:authentication_token_response], @authentication_token
  end

  def process_device_status( message )
    device_status = build_device_status( DeviceStatusMessage.read( message.data ) )

    result = @responder.set_device_status device_status, @authentication_token
    # TODO: Catch bad response and send error back to device
    BinaryMessageBuilder.build Message::MESSAGE_TYPES[:response], Message::ERROR_CODES[:success]
  end

  def process_device_settings( message )
    device_settings = build_device_settings( DeviceSettingsMessage.read( message.data ) )

    result = @responder.update_device_settings device_settings, @authentication_token
    # TODO: Catch bad response and send error back to device
    BinaryMessageBuilder.build Message::MESSAGE_TYPES[:response], Message::ERROR_CODES[:success]
  end

  def process_authentication_request( message )
    token = message.data

    begin
      result = @responder.authenticate token
    rescue ModelTResponder::AuthenticationTokenNotFound
      return BinaryMessageBuilder.build Message::MESSAGE_TYPES[:response], Message::ERROR_CODES[:bad_authentication_token]
    end

    BinaryMessageBuilder.build Message::MESSAGE_TYPES[:response], Message::ERROR_CODES[:authentication_successful]
  end

  def build_device_status( data )
    status = data.status

    device_status = {
      timestamp: data[:timestamp],
      wifi_strength: status[:wifi_strength],
      probes: []
    }

    status.number_of_probes.times do |i|
      device_status[:probes] << { id: i, temperature: status[:probes][i] }
    end

    device_status
  end

  def build_device_settings( data )
    settings = data.settings

    device_settings = {
      timestamp: data.timestamp,
      device_name: settings[:device_name],
      temperature_scale: convert_temperature_scale_to_s( settings[:temperature_scale] ),
      outputs: []
    }

    data.settings.number_of_outputs.times do |i|
      device_settings[:outputs] << {
        id:               i,
        function:         convert_output_function_to_s( settings[:outputs][i][:function] ),
        trigger:          settings[:outputs][i][:trigger],
        setpoint:         settings[:outputs][i][:setpoint],
        compressor_delay: settings[:outputs][i][:compressor_delay],
      }
    end

    device_settings
  end

  def convert_output_function_to_s( function )
    case function
    when 1
      'hot'
    when 2
      'cold'
    else
      'cold'
    end
  end

  def convert_temperature_scale_to_s( scale )
    case scale
    when 1
      return 'F'
    when 2
      return 'C'
    else
      return 'F'
    end
  end
end

