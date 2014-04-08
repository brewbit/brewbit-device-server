require 'sinatra/base'

class WebServer < Sinatra::Base
  # threaded - False: Will take requests on the reactor thread
  #            True:  Will queue request for background thread
  configure do
    set :threaded, false
  end

  post '/devices/:id/activation' do
    data = request.body.read

    puts "Recieved JSON Data: #{data}"

    device_id = data['device_id']
    auth_token = data['auth_token']

    halt 400 if data.nil?

    EM.defer do
    end

    200
  end
end

