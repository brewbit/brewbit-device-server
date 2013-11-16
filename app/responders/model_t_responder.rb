require 'httparty'
require 'json'

class ModelTResponder
  include HTTParty

  BREWBIT_API_URL = "http://brewbit.dev/api"

  attr_accessor :api_version, :device_id

  def get_activation_token
    response = api_get( "activation/new.json", {device_id: @device_id} )
    JSON.parse( response.body )["activation_token"]
    # TODO: check against nil
  end

  def get_authentication_token( activation_token )
    response = api_post( "activation.json", { device_id: self.device_id, activation_token: activation_token } )
    JSON.parse( response.body )["auth_token"]
    # TODO: check against nil
  end

  private

  def api_get( path, query_opts = {} )
    response = HTTParty.get( "#{BREWBIT_API_URL}/v#{self.api_version}/#{path}", query: query_opts )
    # TODO: throw an error if response code is not 200
    response
  end

  def api_post( path, query_opts = {} )
    response = HTTParty.post( "#{BREWBIT_API_URL}/v#{self.api_version}/#{path}", query: query_opts )
    # TODO: throw an error if response code is not 200
    response
  end
end

