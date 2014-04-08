require 'device_manager'
require 'message_parser'
require 'message_handler'

class DeviceConnection < EM::Connection
  attr_reader :device_id
  attr_reader :authenticated

  def post_init
    p 'Connected'

    @device_id = nil
    @authenticated = false
    @parser = MessageParser.new(self)

    DeviceManager.register self
  end

  def unbind
    p 'Closed'
    
    @authenticated = false
    DeviceManager.unregister self
  end
  
  def receive_data( data )
    p "Data: #{data}"
    
    @parser.consume data
  end

  def dispatch_msg( payload )
    MessageHandler.handle self, payload
  end
end
