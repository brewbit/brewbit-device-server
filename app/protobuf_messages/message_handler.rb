require 'messages'
require 'builder'
require 'sender'

module MessageHandler

  class MissingDeviceId < Exception ; end
  class MissingAuthToken < Exception ; end
  class MissingSensorData < Exception ; end
  class UnknownDevice < Exception ; end

  def self.handle( connection, msg )
    p 'Processing Message'
    p "    Message: #{msg.inspect}"

    message = ProtobufMessages::ApiMessage.decode( msg )

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

    # TODO: Send REST message to API

    type = ProtobufMessages::ApiMessage::Type::ACTIVATION_TOKEN_RESPONSE
    data = '3abcd'
    response_message = ProtobufMessages::Builder.build( type, data )

    send_response response_message, connection
  end

  def self.auth_request( message, connection )
    # raise MissingDeviceId if message.authRequest.device_id.blank?
    raise MissingAuthToken if message.authRequest.auth_token.blank?

    Rails.logger.info 'Processing Auth Request'
    Rails.logger.info "    Message: #{message.inspect}"

    device_id = message.authRequest.device_id
    auth_token = message.authRequest.auth_token

    authenticated = connection.authenticate auth_token

    type = ProtobufMessages::ApiMessage::Type::AUTH_RESPONSE
    response_message = ProtobufMessages::Builder.build( type, authenticated )

    send_response response_message, connection
  end

  def self.device_report( message, connection )
    raise MissingSensorData if message.deviceReport.sensor_report.blank?

    return if !connection.authenticated

    Rails.logger.info 'Process Device Report'
    Rails.logger.info "    Message: #{message.inspect}"

    device = connection.device

    raise UnknownDevice if device.blank?

    message.deviceReport.sensor_report.each do |sensor|
      reading = sensor.value
      setpoint = sensor.setpoint
      sensor_id = sensor.id
      SensorReadingsService.record reading, setpoint, device, sensor_id
    end
  end

  def self.firmware_download_request( message, connection )
    Rails.logger.info 'Process Firmware Download Request'
    Rails.logger.info "    Message: #{message.inspect}"

    return if !connection.authenticated

    version = message.firmwareDownloadRequest.requested_version

    type = ProtobufMessages::ApiMessage::Type::FIRMWARE_DOWNLOAD_RESPONSE

    firmware = FirmwareVersionManager.get_firmware( version )

    firmware_data = FirmwareSerializer.new( firmware.file )
    total_packets = firmware.size

    firmware_data.each_with_index do |chunk, i|
      offset = i * FirmwareSerializer::CHUNK_SIZE
      data = { offset: offset, chunk: chunk }
      response_message = ProtobufMessages::Builder.build( type, data )
      send_response response_message, connection
    end
  end

  def self.firmware_update_check_request( message, connection )
    Rails.logger.info 'Process Firmware Update Check Request'
    Rails.logger.info "    Message: #{message.inspect}"

    return if !connection.authenticated

    current_version = message.firmwareUpdateCheckRequest.current_version

    type = ProtobufMessages::ApiMessage::Type::FIRMWARE_UPDATE_CHECK_RESPONSE
    data = {}
    if FirmwareVersionManager.update_available?( current_version )
      update_info = FirmwareVersionManager.get_latest_version_info
      unless update_info.blank?
        data[:update_available] = true
        data[:version] = update_info[:version]
        data[:binary_size] = update_info[:size]
      else
        data[:update_available] = false
      end
    else
      data[:update_available] = false
    end

    response_message = ProtobufMessages::Builder.build( type, data )
    send_response response_message, connection
  end

  def self.device_settings_notification( message, connection )
    Rails.logger.info 'Process Device Settings Notification'
    Rails.logger.info "    Message: #{message.inspect}"

    return if !connection.authenticated

    device = Device.find_by( hardware_identifier: connection.device_id )

    if device
      device.name = message.deviceSettingsNotification.name

      message.deviceSettingsNotification.output.each do |o|
        if output = device.outputs.find_by( output_index: o.id )
          output.function = Output::FUNCTIONS.values.index( o.function )
          output.cycle_delay = o.cycle_delay
          output.sensor = device.sensors.find_by( sensor_index: o.trigger_sensor_id )

          output.save
        end
      end

      message.deviceSettingsNotification.sensor.each do |s|
        if sensor = device.sensors.find_by( sensor_index: s.id )
          sensor.setpoint_type = s.setpoint_type

          case s.setpoint_type
          when ProtobufMessages::SensorSettings::SetpointType::STATIC
            sensor.static_setpoint = s.static_setpoint
          when ProtobufMessages::SensorSettings::SetpointType::TEMP_PROFILE
            sensor.temp_profile_id = s.temp_profile_id
          end

          sensor.save
        end
      end
    end

    device.save
  end

  private

  def self.send_response( message, connection )
    ProtobufMessages::Sender.send( message, connection )
  end
end

