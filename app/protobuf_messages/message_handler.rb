require 'messages'
require 'builder'
require 'sender'
require 'web_api'
require 'firmware_serializer'

module MessageHandler

  class MissingDeviceId < Exception ; end
  class MissingAuthToken < Exception ; end
  class MissingSensorData < Exception ; end
  class UnknownDevice < Exception ; end

  def self.handle( connection, msg )
    p "Processing Message from #{connection.device_id}"
    p "    raw message: #{msg.inspect}"

    message = ProtobufMessages::ApiMessage.decode( msg )
    p "    decoded message: #{message.inspect}"

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
    when ProtobufMessages::ApiMessage::Type::DEVICE_SETTINGS_NOTIFICATION
      device_settings_notification message, connection
    end
  end

  private

  def self.activation_token_request( message, connection )
    p 'Processing Activation Token Request'
    p "    Message: #{message.inspect}"

    device_id = message.activationTokenRequest.device_id
    connection.device_id = device_id

    data = WebApi.get_activation_token( device_id )
    type = ProtobufMessages::ApiMessage::Type::ACTIVATION_TOKEN_RESPONSE
    response_message = ProtobufMessages::Builder.build( type, data )

    send_response response_message, connection
  end

  def self.auth_request( message, connection )
    raise MissingAuthToken if message.authRequest.auth_token.nil? || message.authRequest.auth_token.empty?

    p 'Processing Auth Request'
    p "    Message: #{message.inspect}"

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

    p 'Process Device Report'
    p "    Message: #{message.inspect}"

    auth_token = connection.auth_token
    device_id = connection.device_id

    options = {
      auth_token: auth_token,
      controller_reports:
        message.deviceReport.controller_reports.collect { |report| {
          controller_index: report.controller_index,
          sensor_reading:   report.sensor_reading,
          setpoint:         report.setpoint
        }
      }
    }

    WebApi.send_device_report( device_id, options )
  end

  def self.firmware_download_request( message, connection )
    p 'Process Firmware Download Request'
    p "    Message: #{message.inspect}"

    return if !connection.authenticated

    version = message.firmwareDownloadRequest.requested_version

    firmware = WebApi.get_firmware( version )
    return if firmware.nil? || firmware.empty?

    firmware_data = FirmwareSerializer.new( firmware )
    total_packets = firmware.size

    type = ProtobufMessages::ApiMessage::Type::FIRMWARE_DOWNLOAD_RESPONSE
    firmware_data.each_with_index do |chunk, i|
      offset = i * FirmwareSerializer::CHUNK_SIZE
      data = { offset: offset, chunk: chunk }
      response_message = ProtobufMessages::Builder.build( type, data )
      send_response response_message, connection
    end
  end

  def self.firmware_update_check_request( message, connection )
    p 'Process Firmware Update Check Request'
    p "    Message: #{message.inspect}"

    return if !connection.authenticated

    current_version = message.firmwareUpdateCheckRequest.current_version

    response = WebApi.firmware_update_available?( device_id, current_version )
    data = {}

    type = ProtobufMessages::ApiMessage::Type::FIRMWARE_UPDATE_CHECK_RESPONSE
    if response.nil? || response.empty?
      data[:update_available] = false
    else
      data[:update_available] = true
      data[:version] = response["version"]
      data[:binary_size] = response["size"]
    end

    response_message = ProtobufMessages::Builder.build( type, data )
    send_response response_message, connection
  end

  def self.device_settings_notification( message, connection )
    p 'Process Device Settings Notification'
    p "    Message: #{message.inspect}"

    return if !connection.authenticated

    device_id = connection.device_id

    device = { outputs: [], sensors: []}

    device[:name] = message.deviceSettingsNotification.name

    message.deviceSettingsNotification.output.each do |o|
      output = {}
      output[:id] =
      output[:function] = o.function
      output[:cycle_delay] = o.cycle_delay
      output[:sensor] = o.trigger_sensor_id
      output[:mode] = o.output_mode

      device[:outputs] << output
    end

    message.deviceSettingsNotification.sensor.each do |s|
      sensor = {}
      sensor[:id] = s.id
      sensor[:setpoitn_type] = s.setpoint_type
      sensor[:static_setpoint] = s.static_setpoint
      sensor[:temp_profile_id] = s.temp_profile_id

      device[:sensors] << sensor
    end

    WebApi.send_device_settings( device_id, device )
  end

  private

  def self.send_response( message, connection )
    ProtobufMessages::Sender.send( message, connection )
  end
end

