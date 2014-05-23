require 'messages'
require 'builder'
require 'sender'
require 'web_api'

module MessageHandler

  class MissingDeviceId < Exception ; end
  class MissingAuthToken < Exception ; end
  class MissingSensorData < Exception ; end
  class UnknownDevice < Exception ; end

  def self.handle( connection, msg )
    Log.debug "Processing Message from #{connection.device_id}"
    Log.debug "    raw message: #{msg.inspect}"

    message = ProtobufMessages::ApiMessage.decode( msg.dup )
    Log.debug "    decoded message: #{message.inspect}"

    case message.type
    when ProtobufMessages::ApiMessage::Type::ACTIVATION_TOKEN_REQUEST
      activation_token_request message, connection
    when ProtobufMessages::ApiMessage::Type::AUTH_REQUEST
      auth_request message, connection
    when ProtobufMessages::ApiMessage::Type::DEVICE_REPORT
      device_report message, connection
    when ProtobufMessages::ApiMessage::Type::FIRMWARE_DOWNLOAD_REQUEST
      firmware_download_request message, connection
    when ProtobufMessages::ApiMessage::Type::FIRMWARE_UPDATE_CHECK_REQUEST
      firmware_update_check_request message, connection
    when ProtobufMessages::ApiMessage::Type::CONTROLLER_SETTINGS
      controller_settings_notification message, connection
    end
  end

  private

  def self.activation_token_request( message, connection )
    Log.debug 'Processing Activation Token Request'
    Log.debug "    Message: #{message.inspect}"

    device_id = message.activationTokenRequest.device_id
    connection.device_id = device_id

    data = WebApi.get_activation_token( device_id )
    type = ProtobufMessages::ApiMessage::Type::ACTIVATION_TOKEN_RESPONSE
    response_message = ProtobufMessages::Builder.build( type, data )

    send_response response_message, connection
  end

  def self.auth_request( message, connection )
    raise MissingAuthToken if message.authRequest.auth_token.nil? || message.authRequest.auth_token.empty?

    Log.debug 'Processing Auth Request'
    Log.debug "    Message: #{message.inspect}"

    device_id = message.authRequest.device_id
    auth_token = message.authRequest.auth_token

    connection.device_id = device_id
    connection.auth_token = auth_token

    connection.authenticated = WebApi.authenticate( device_id, auth_token )
    type = ProtobufMessages::ApiMessage::Type::AUTH_RESPONSE
    response_message = ProtobufMessages::Builder.build( type, connection.authenticated )

    send_response response_message, connection
  end

  def self.device_report( message, connection )
    raise MissingSensorData if message.deviceReport.controller_reports.nil? || message.deviceReport.controller_reports.empty?

    return if !connection.authenticated

    Log.debug 'Process Device Report'
    Log.debug "    Message: #{message.inspect}"

    auth_token = connection.auth_token
    device_id = connection.device_id

    options = {
      auth_token: auth_token,
      controller_reports:
        message.deviceReport.controller_reports.collect { |report| {
          controller_index: report.controller_index,
          sensor_reading:   report.sensor_reading,
          setpoint:         report.setpoint,
          timestamp:        report.timestamp
        }
      }
    }

    WebApi.send_device_report( device_id, options )
  end

  def self.firmware_download_request( message, connection )
    Log.debug 'Process Firmware Download Request'
    Log.debug "    Message: #{message.inspect}"

    return if !connection.authenticated

    auth_token = connection.auth_token
    device_id = connection.device_id
    version = message.firmwareDownloadRequest.requested_version
    offset = message.firmwareDownloadRequest.offset
    size = message.firmwareDownloadRequest.size

    data = WebApi.get_firmware( device_id, version, offset, size, auth_token )
    return if data.nil? || data.empty?

    type = ProtobufMessages::ApiMessage::Type::FIRMWARE_DOWNLOAD_RESPONSE
    params = { offset: offset, data: data }
    response_message = ProtobufMessages::Builder.build( type, params )
    send_response response_message, connection
  end

  def self.firmware_update_check_request( message, connection )
    Log.debug 'Process Firmware Update Check Request'
    Log.debug "    Message: #{message.inspect}"

    return if !connection.authenticated

    auth_token = connection.auth_token
    current_version = message.firmwareUpdateCheckRequest.current_version

    response = WebApi.firmware_update_available?( connection.device_id, current_version, auth_token )
    data = {}

    type = ProtobufMessages::ApiMessage::Type::FIRMWARE_UPDATE_CHECK_RESPONSE
    if response.nil? || !response['update_available']
      data[:update_available] = false
    else
      data[:update_available] = true
      data[:version] = response["version"]
      data[:binary_size] = response["binary_size"]
    end

    response_message = ProtobufMessages::Builder.build( type, data )
    send_response response_message, connection
  end

  def self.controller_settings_notification( message, connection )
    Log.debug 'Process Device Settings Notification'
    Log.debug "    Message: #{message.inspect}"

    return if !connection.authenticated

    auth_token = connection.auth_token
    device_id = connection.device_id

    data = {
      auth_token: auth_token,
      name: message.controllerSettings.name,
      sensor_index: message.controllerSettings.sensor_index,
      setpoint_type: message.controllerSettings.setpoint_type,
      static_setpoint: message.controllerSettings.static_setpoint,
      temp_profile_id: message.controllerSettings.temp_profile_id,
      output_settings: []
    }

    unless message.controllerSettings.output_settings.nil?
      message.controllerSettings.output_settings.each do |o|
        data[:output_settings] << {
          index:        o.index,
          function:     o.function,
          cycle_delay:  o.cycle_delay
        }
      end
    end

    WebApi.send_controller_settings( device_id, data )
  end

  private

  def self.send_response( message, connection )
    ProtobufMessages::Sender.send( message, connection )
  end
end

