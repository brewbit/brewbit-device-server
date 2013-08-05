require 'bindata'

class TemperaturePointArray < BinData::Array

  endian ENDIAN

  uint32  :point_index
  uint64  :duration # in minutes
  uint8   :transition
  float   :temperature
end

class TemperatureProfileData < BinData::Record

  TRANSITION_TYPE = {
    ramp: 0,
    step: 1
  }

  endian ENDIAN

  uint32                  :name_length
  string                  :name, length: :name_length
  uint32                  :number_of_points
  temperature_point_array :points, initial_length: :number_of_points
end

