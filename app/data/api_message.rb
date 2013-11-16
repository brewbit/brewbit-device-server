require 'bindata'

class ApiMessage < BinData::Record

  endian ENDIAN

  uint8   :api_version
  uint64  :device_id

  SUPPORTED_API_VERSIONS = {
    one: 1
  }

  def process
    if api_version_supported?
      return Message::ERROR_CODES[:success]
    else
      return Message::ERROR_CODES[:api_version_not_supported]
    end
  end

  private

  def api_version_supported?
    SUPPORTED_API_VERSIONS.has_value? self.api_version
  end
end

