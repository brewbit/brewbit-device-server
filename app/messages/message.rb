require 'bindata'
require 'crc'

class Message < BinData::Record
  SYNC1 = 0xB3
  SYNC2 = 0xEB
  SYNC3 = 0x17

  MESSAGE_TYPES = {
    version:          0,
    activation:       1,
    authentication:   2,
    device_settings:  3,
    temp_profile:     4,
    upgrade:          5,
    ack:              6,
    nack:             7,
    temperature:      8
  }

  endian ENDIAN

  uint8  :sync1, initial_value: SYNC1
  uint8  :sync2, initial_value: SYNC2
  uint8  :sync3, initial_value: SYNC3
  uint8  :message_type
  uint32 :data_length
  string :data, length: :data_length, onlyif: :has_data?
  uint16 :crc

  def has_data?
    data_length > 0
  end

  def build_crc
    buffer = self.to_binary_s[3...-2]
    self.crc = Crc.crc16 buffer
  end
end

