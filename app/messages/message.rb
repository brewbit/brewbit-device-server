require 'bindata'
require 'crc'

class Message < BinData::Record
  START_MESSAGE = 0xB3EB17

  MESSAGE_TYPES = {
    version:          0,
    activation:       1,
    authentication:   2,
    device_settings:  3,
    profile:          4,
    upgrade:          5,
    ack:              6,
    nack:             7,
    temperature:      8
  }

  endian ENDIAN

  uint24 :start_message, initial_value: START_MESSAGE
  uint8  :message_type
  uint32 :data_length, onlyif: :has_data?
  string :data, length: :data_length, onlyif: :has_data?
  uint16 :crc

  def has_data?
    !is_ack_message? && !is_nack_message?
  end

  def build_crc
    buffer = self.to_binary_s[0...-2]
    self.crc = Crc.crc16 buffer
  end

  private

  def is_ack_message?
    message_type == MESSAGE_TYPES[:ack]
  end

  def is_nack_message?
    message_type == MESSAGE_TYPES[:nack]
  end
end

