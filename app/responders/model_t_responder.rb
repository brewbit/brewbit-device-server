require 'httparty'
require 'json'

module ModelTResponder
  include HTTParty

  def self.get_activation_token( device_id )
    response = api_get( device_id, "activation/new.json" )
    token = JSON.parse( response.body )["activation_token"]

    return nil if token.empty? || response.code != 200

    token
  end

  def self.authenticate( device_id, authentication_token )
    response = api_get( device_id, "auth/new.json", { authentication_token: authentication_token } )

    return false if response.code != 200

    true
  end

  def self.send_device_report( device_id, options )
    response = api_post( device_id, 'reports', options )

    return false if response.code != 200

    response
  end

  def self.firmware_update_available?( device_id, version )
    options = { current_version: version }

    response = api_get( device_id, 'firmware/check.json', options )

    return false if response.code != 200

    JSON.parse( response.body)["update"]
  end

  def self.get_firmware( device_id, version )
    options = { version: version }

    response = api_get( device_id, 'firmware/show.json', options )

    return nil if response.code != 200

    JSON.parse( response.body )['firmware']
  end

  def self.send_device_settings( device_id, options )
    response = api_post( device_id, 'settings.json', options )

    return nil if response.code != 200

    true
  end

  def self.api_get( device_id, path, query_opts = {} )
    # TODO resque errors
    HTTParty.get( "#{BREWBIT_API_URL}/v#{API_VERSION}/devices/#{device_id}/#{path}", query: query_opts )
  end

  def self.api_post( device_id, path, query_opts = {} )
    # TODO resque errors
    HTTParty.post( "#{BREWBIT_API_URL}/v#{API_VERSION}/devices/#{device_id}/#{path}", query: query_opts )
  end
end

