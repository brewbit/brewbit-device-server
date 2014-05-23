require 'httparty'
require 'json'

module WebApi
  include HTTParty
  
  class ApiError < StandardError
    attr_reader :response_code

    def initialize(response_code)
      @response_code = response_code
    end
  end

  def self.get_activation_token( device_id )
    response = api_get( device_id, "activation/new.json" )
    token = response["activation_token"]

    raise if token.nil? || token.empty?

    token
  end

  def self.authenticate( device_id, auth_token )
    begin
      api_get( device_id, "auth/new.json", { auth_token: auth_token } )
      true
    rescue ApiError => e
      if e.response_code == 401 || e.response_code == 404
        false
      else
        raise        
      end
    end
  end

  def self.send_device_report( device_id, options )
    begin
      api_post( device_id, 'reports', options )
      true
    rescue
      Log.error $!.inspect
      Log.error $@
      false
    end
  end

  def self.firmware_update_available?( device_id, version, auth_token )
    begin
      options = {
        auth_token: auth_token,
        current_version: version
      }
      response = api_get( device_id, 'firmware/check.json', options )

      response
    rescue
      Log.error $!.inspect
      Log.error $@
      nil
    end
  end

  def self.get_firmware( device_id, version, offset, size, auth_token )
    begin
      options = {
        auth_token: auth_token,
        version: version,
        offset: offset,
        size: size
      }

      response = api_get( device_id, 'firmware/show.json', options )
      Base64.decode64(response['data'])
    rescue
      Log.error $!.inspect
      Log.error $@
      nil
    end
  end

  def self.send_controller_settings( device_id, options )
    begin
      response = api_post( device_id, 'controller_settings.json', options )
      true
    rescue
      Log.error $!.inspect
      Log.error $@
      nil
    end
  end

  private

  def self.api_get( device_id, path, options = {} )
    api_send( :get, device_id, path, options )
  end

  def self.api_post( device_id, path, options = {} )
    api_send( :post, device_id, path, options )
  end

  def self.api_send( method, device_id, path, options )
    url = "#{BREWBIT_API_URL}/v#{API_VERSION}/devices/#{device_id}/#{path}"
    Log.debug "Sending request to #{url}"
    Log.debug "    #{options.inspect}"

    response = HTTParty.send(
                  method,
                  url,
                  body: options.to_json,
                  headers: {
                    'Accept' => 'application/json',
                    'Content-Type' => 'application/json' } )
    Log.debug "    Server returned: #{response.code} #{response.body}"

    response_json = JSON.parse( response.body )

    if response.code != 200
      message = response_json['message']
      Log.debug "Request failed: #{message}"
      raise ApiError.new(response.code), message
    end

    response_json
  end
end

