require 'httparty'
require 'json'

module WebApi
  include HTTParty

  def self.get_activation_token( device_id )
    begin
      response = api_get( device_id, "activation/new.json" )
      token = response["activation_token"]
      
      raise if token.empty?
      
      token
    rescue
      puts $!.inspect, $@
      nil
    end
  end

  def self.authenticate( device_id, auth_token )
    begin
      api_get( device_id, "auth/new.json", { auth_token: auth_token } )
      true
    rescue
      puts $!.inspect, $@
      false
    end
  end

  def self.send_device_report( device_id, options )
    begin
      api_post( device_id, 'reports', options )
      true
    rescue
      puts $!.inspect, $@
      false
    end
  end

  def self.firmware_update_available?( device_id, version )
    begin
      options = { current_version: version }
      response = api_get( device_id, 'firmware/check.json', options )
      
      response['update']
    rescue
      puts $!.inspect, $@
      false
    end
  end

  def self.get_firmware( device_id, version )
    begin
      options = { version: version }

      response = api_get( device_id, 'firmware/show.json', options )

      response['firmware']
    rescue
      puts $!.inspect, $@
      nil
    end
  end

  def self.send_device_settings( device_id, options )
    begin
      response = api_post( device_id, 'settings.json', options )
      true
    rescue
      puts $!.inspect, $@
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
    p "Sending request to #{url}"
    p "    #{options.inspect}"
    
    response = HTTParty.send(
                  method,
                  url,
                  body: options.to_json,
                  headers: { 'Content-Type' => 'application/json' } )
    p "    Server returned: #{response.code} #{response.body}"
    
    response_json = JSON.parse( response.body )
    
    if response.code != 200
      message = response_json['message']
      p "Request failed: #{message}"
      raise message
    end
    
    response_json
  end
end

