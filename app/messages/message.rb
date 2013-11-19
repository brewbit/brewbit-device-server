require 'bindata'

class Message < BinData::Record
  SYNC1 = 0xB3
  SYNC2 = 0xEB
  SYNC3 = 0x17

  MESSAGE_TYPES = {
    response:                       0,
    api_version:                    1,
    activation_token_request:       2,
    activation_token_response:      3,
    authentication_token_request:   4,
    authentication_token_response:  5,
    authentication_request:         6,
    device_status:                  7,
    device_settings:                8,
    temperature_profile:            9,
    upgrade:                        10
  }

  ERROR_CODES = {
    success:                        0,
    activation_token_not_found:     1,
    crc_failed:                     2,
    api_version_not_supported:      3,
    device_not_found:               4,
    bad_authentication_token:       5,
    authentication_successful:      6,
    failed_to_get_activation_token: 7
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
    self.data_length > 0
  end

  def build_crc
    self.crc = Digest::CRC16.checksum( self.to_binary_s[3...-2] )
  end

  def valid?
    valid_crc = Digest::CRC16.checksum( self.to_binary_s[3...-2] )

    self.crc == valid_crc
  end

  def error_string_from_code( code )
    ERROR_CODES.key( code ).to_s.sub(/_/, ' ' ).capitalize
  end
end

