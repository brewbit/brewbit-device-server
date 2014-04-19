require 'protobuf_messages/messages'

module ProtobufMessages::Builder

  def self.build( type, data )
    case type
    when ProtobufMessages::ApiMessage::Type::ACTIVATION_NOTIFICATION
      return build_activation_notification data
    when ProtobufMessages::ApiMessage::Type::ACTIVATION_TOKEN_RESPONSE
      return build_activation_token_response data
    when ProtobufMessages::ApiMessage::Type::AUTH_RESPONSE
      return build_auth_response data
    when ProtobufMessages::ApiMessage::Type::FIRMWARE_DOWNLOAD_RESPONSE
      return build_firmware_download_response data
    when ProtobufMessages::ApiMessage::Type::FIRMWARE_UPDATE_CHECK_RESPONSE
      return build_firmware_update_check_response data
    when ProtobufMessages::ApiMessage::Type::DEVICE_SETTINGS
      return build_device_settings data
    when ProtobufMessages::ApiMessage::Type::CONTROLLER_SETTINGS
      return build_controller_settings data
    end
  end

  private

  def self.build_activation_notification( auth_token )
    message = ProtobufMessages::ApiMessage.new
    message.type = ProtobufMessages::ApiMessage::Type::ACTIVATION_NOTIFICATION
    message.activationNotification = ProtobufMessages::ActivationNotification.new
    message.activationNotification.auth_token = auth_token

    message
  end

  def self.build_activation_token_response( activation_token )
    message = ProtobufMessages::ApiMessage.new
    message.type = ProtobufMessages::ApiMessage::Type::ACTIVATION_TOKEN_RESPONSE
    message.activationTokenResponse = ProtobufMessages::ActivationTokenResponse.new
    message.activationTokenResponse.activation_token = activation_token

    message
  end

  def self.build_auth_response( authenticated )
    message = ProtobufMessages::ApiMessage.new
    message.type = ProtobufMessages::ApiMessage::Type::AUTH_RESPONSE
    message.authResponse = ProtobufMessages::AuthResponse.new
    message.authResponse.authenticated = authenticated

    message
  end

  def self.build_firmware_download_response( data )
    message = ProtobufMessages::ApiMessage.new
    message.type = ProtobufMessages::ApiMessage::Type::FIRMWARE_DOWNLOAD_RESPONSE
    message.firmwareDownloadResponse = ProtobufMessages::FirmwareDownloadResponse.new
    message.firmwareDownloadResponse.offset = data[:offset]
    message.firmwareDownloadResponse.data = data[:data]

    message
  end

  def self.build_firmware_update_check_response( data )
    message = ProtobufMessages::ApiMessage.new
    message.type = ProtobufMessages::ApiMessage::Type::FIRMWARE_UPDATE_CHECK_RESPONSE
    message.firmwareUpdateCheckResponse = ProtobufMessages::FirmwareUpdateCheckResponse.new
    message.firmwareUpdateCheckResponse.update_available = data[:update_available]
    message.firmwareUpdateCheckResponse.version = data[:version]
    message.firmwareUpdateCheckResponse.binary_size = data[:binary_size]

    message
  end

  def self.build_device_settings( data )
    message = ProtobufMessages::ApiMessage.new
    message.type = ProtobufMessages::ApiMessage::Type::DEVICE_SETTINGS
    message.deviceSettings = ProtobufMessages::DeviceSettings.new
    
    message.deviceSettings.name = data['name']
    message.deviceSettings.control_mode = data['control_mode']
    
    message
  end

  def self.build_controller_settings( data )
    message = ProtobufMessages::ApiMessage.new
    message.type = ProtobufMessages::ApiMessage::Type::CONTROLLER_SETTINGS
    message.controllerSettings = ProtobufMessages::ControllerSettings.new
    
    message.controllerSettings.name = data['name']
    message.controllerSettings.sensor_index = data['sensor_index']
    message.controllerSettings.setpoint_type = data['setpoint_type']

    case message.controllerSettings.setpoint_type
    when ProtobufMessages::ControllerSettings::SetpointType::STATIC
      message.controllerSettings.static_setpoint = data['static_setpoint']
    when ProtobufMessages::ControllerSettings::SetpointType::TEMP_PROFILE
      message.controllerSettings.temp_profile_id = data['temp_profile_id']
    end

    message.controllerSettings.output_settings = []
    data['output_settings'].each do |o|
      output = ProtobufMessages::OutputSettings.new
      output.index = o['index']
      output.function = o['function']
      output.cycle_delay = o['cycle_delay']
      output.output_mode = o['output_mode']
      message.controllerSettings.output_settings << output
    end

    message.controllerSettings.temp_profiles = []
    data['temp_profiles'].each do |s|
      temp_profile = ProtobufMessages::TempProfile.new
      temp_profile.id          = s['id']
      temp_profile.name        = s['name']
      temp_profile.start_value = s['start_value']
      temp_profile.steps       = []
      s['steps'].each do |st|
        temp_profile_step = ProtobufMessages::TempProfileStep.new
        temp_profile_step.duration = st['duration']
        temp_profile_step.value    = st['value']
        temp_profile_step.type     = st['type']
        
        temp_profile.steps << temp_profile_step
      end

      message.controllerSettings.temp_profiles << temp_profile
    end

    message
  end
end

