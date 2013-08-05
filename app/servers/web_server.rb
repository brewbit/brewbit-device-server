require 'sinatra/base'

class WebServer < Sinatra::Base
  # threaded - False: Will take requests on the reactor thread
  #            True:  Will queue request for background thread
  configure do
    set :threaded, false
  end

  post '/temperature_profile' do
    data = request.body.read

    halt 400 if data.nil?

    EM.defer do
      msg = MessageBuilder.build Message::MESSAGE_TYPES[:temp_profile], data

      dev = ModelTServer.devices.first
      dev.send_message msg
    end

    200
  end
end

