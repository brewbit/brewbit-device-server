require 'sinatra/base'

class WebServer < Sinatra::Base
  # threaded - False: Will take requests on the reactor thread
  #            True:  Will queue request for background thread
  configure do
    set :threaded, false
  end

  post '/devices/:device_id/activation' do
    data = JSON.parse(request.body.read)

    halt 400 if data.nil?

    Log.debug "Recieved JSON Data: #{data.inspect}"

    device_id = params['device_id']
    halt 400 unless device_id

    auth_token = data['auth_token']
    halt 400 unless auth_token

    connections = DeviceManager.find_all_by_device_id device_id
    halt 404 unless connections.any?

    message = ProtobufMessages::Builder.build( ProtobufMessages::ApiMessage::Type::ACTIVATION_NOTIFICATION, auth_token )

    connections.each do |connection|
      connection.auth_token = auth_token
      connection.authenticated = true
      ProtobufMessages::Sender.send message, connection
    end

    200
  end

  post '/devices/:device_id/device_settings' do
    data = JSON.parse(request.body.read)

    halt 400 if data.nil?

    Log.debug "Recieved device settings. Data: #{data.inspect}"

    device_id = params['device_id']
    halt 400 unless device_id

    message = ProtobufMessages::Builder.build( ProtobufMessages::ApiMessage::Type::DEVICE_SETTINGS, data )
    send_to_all device_id, message

    200
  end

  post '/devices/:device_id/controller_settings' do
    data = JSON.parse(request.body.read)

    halt 400 if data.nil?

    Log.debug "Recieved controller settings. Data: #{data.inspect}"

    device_id = params['device_id']
    halt 400 unless device_id

    message = ProtobufMessages::Builder.build( ProtobufMessages::ApiMessage::Type::CONTROLLER_SETTINGS, data )
    send_to_all device_id, message

    200
  end

  delete '/devices/:device_id' do
    device_id = params['device_id']
    halt 400 unless device_id

    DeviceManager.unregister_all( device_id )

    200
  end
  
  def send_to_all(device_id, message)
    connections = DeviceManager.find_all_by_device_id device_id
    halt 404 unless connections.any?
    
    connections.each do |connection|
      ProtobufMessages::Sender.send message, connection
    end
  end
end

