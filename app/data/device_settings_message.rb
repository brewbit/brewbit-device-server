require 'bindata'

class OutputData < BinData::Record
  endian ENDIAN

  uint8   :function
  uint8   :trigger
  uint32  :setpoint
  uint32  :compressor_delay
end

class DeviceSettings < BinData::Record
  endian ENDIAN

  uint32        :device_name_length
  string        :device_name, read_length: :device_name_length
  uint8         :temperature_scale
  uint32        :number_of_outputs
  array  :outputs, type: :output_data, initial_length: :number_of_outputs
end

class DeviceSettingsMessage < BinData::Record
  endian ENDIAN

  uint32          :timestamp
  device_settings :settings
end

