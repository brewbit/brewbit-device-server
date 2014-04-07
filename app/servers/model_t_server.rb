require 'device_manager'

class ModelTServer < EM::Connection

  def post_init
    p 'Connected'
    DeviceManager.new( self )
  end

  def unbind
    p 'Closed'
    connection = DeviceManager.find_by_connection self
    connection.delete if connection
  end

  def receive_data( data )
    p "Data: #{data}"
    DeviceManager.handle( self, data )
  end

  def send_message( message )
    send_data message
  end
end

