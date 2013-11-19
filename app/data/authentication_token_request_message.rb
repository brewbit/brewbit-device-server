require 'bindata'

class AuthenticationTokenRequestMessage < BinData::Record

  endian ENDIAN

  uint48 :activation_token
end

