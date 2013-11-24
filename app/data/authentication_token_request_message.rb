require 'bindata'

class AuthenticationTokenRequestMessage < BinData::Record

  endian ENDIAN

  uint64 :activation_token
end

