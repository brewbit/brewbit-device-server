require 'sinatra/base'

class WebServer < Sinatra::Base
  # threaded - False: Will take requests on the reactor thread
  #            True:  Will queue request for background thread
  configure do
    set :threaded, false
  end
  
  post '/devices/:device_id/activate' do
    data = request.body.read

    puts "Recieved activate notification. Data: #{data}"

    200    
  end
  
  post '/devices/:device_id/commands' do
    data = request.body.read

    puts "Recieved device command. Data: #{data}"

    200    
  end

  post '/temperature_profile' do
    data = request.body.read

    puts "Recieved JSON Data: #{data}"

    halt 400 if data.nil?

    EM.defer do
      #msg = MessageBuilder.build Message::MESSAGE_TYPES[:temp_profile], data

      dev = ModelTServer.devices.first
      dev.send_message msg
    end

    200
  end
end

