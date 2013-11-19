require 'httparty'
require 'json'

class ModelTResponder
  include HTTParty

  BREWBIT_API_URL = "http://brewbit.dev/api"

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

  def get_authentication_token( activation_token )
    response = api_post( "activation", { device_id: @device.id, activation_token: activation_token } )
    token = JSON.parse( response.body )['auth_token']

    raise ActivationTokenNotFound if response.code == 404

    token
  end

  def authenticate( authentication_token )
    response = api_post( "authentication", { device_id: @device.id, authentication_token: authentication_token } )

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
    HTTParty.get( "#{BREWBIT_API_URL}/v#{@device.api_version}/#{path}", query: query_opts )
  end

  def api_post( path, query_opts = {} )
    HTTParty.post( "#{BREWBIT_API_URL}/v#{@device.api_version}/#{path}", query: query_opts )
  end
end

