require 'bindata'

class DeviceStatus < BinData::Record
  endian ENDIAN

  uint32  :wifi_strength
  uint32  :number_of_probes
  array   :probes, type: :uint32, initial_length: :number_of_probes
end

class DeviceStatusMessage < BinData::Record
  endian ENDIAN

  uint32        :timestamp
  device_status :status
end

