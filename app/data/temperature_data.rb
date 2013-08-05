require 'bindata'

class TemperatureData < BinData::Record

  endian ENDIAN

  uint8 :probe
  float :temperature
end

