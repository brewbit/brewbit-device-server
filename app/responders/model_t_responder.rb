require 'httparty'
require 'json'

class ModelTResponder
  include HTTParty

  class FailedToGetActivationToken < Exception ; end
  class ActivationTokenNotFound < Exception ; end
  class AuthenticationTokenNotFound < Exception ; end

  def initialize( device )
    @device = device
  end

  def get_activation_token
    response = api_get( "activation/new.json", {device_id: @device.id} )
    token = JSON.parse( response.body )["activation_token"]

    raise FailedToGetActivationToken if token.empty? || response.code != 200

    token
  end

  def authenticate( authentication_token )
    response = api_post( "account/authenticate.json", { device_id: @device.id, authentication_token: authentication_token.to_binary_s } )

    raise AuthenticationTokenNotFound if response.code != 200

    true
  end

  def set_device_status( status, authentication_token )
    response = api_post( "devices/#{@device.id}", { authentication_token: authentication_token, device: status } )
    response.header.code == "201"
    # TODO: handle non-201 responses
  end

  def update_device_settings( settings, authentication_token )
    response = api_post( "devices/#{@device.id}", { authentication_token: authentication_token, device: settings } )
    response.header.code == "201"
    # TODO: handle non-201 response
  end

  private

  def api_get( path, query_opts = {} )
    # TODO resque errors
    HTTParty.get( "#{BREWBIT_API_URL}/v#{@device.api_version}/#{path}", query: query_opts )
  end

  def api_post( path, query_opts = {} )
    # TODO resque errors
    HTTParty.post( "#{BREWBIT_API_URL}/v#{@device.api_version}/#{path}", query: query_opts )
  end
end

