require 'sinatra/base'

class WebServer < Sinatra::Base
  # threaded - False: Will take requests on the reactor thread
  #            True:  Will queue request for background thread
  configure do
    set :threaded, false
  end

  post '/devices/:device_id/activation' do
    data = JSON.parse(request.body.read)

    puts "Recieved JSON Data: #{data.inspect}"

    halt 400 if data.nil?

    device_id = params['device_id']
    halt 400 unless device_id
    
    auth_token = data['auth_token']
    halt 400 unless auth_token

    connection = DeviceManager.find_by_device_id device_id
    halt 404 unless connection
    
    connection.auth_token = auth_token
    
    message = ProtobufMessages::Builder.build( ProtobufMessages::ApiMessage::Type::ACTIVATION_NOTIFICATION, auth_token )
    ProtobufMessages::Sender.send message, connection
    
    200
  end

  post '/devices/:device_id/commands' do
    data = request.body.read

    puts "Recieved device command. Data: #{data}"

    200
  end
end

