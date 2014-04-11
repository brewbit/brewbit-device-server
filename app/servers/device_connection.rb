require 'device_manager'
require 'message_parser'
require 'message_handler'

class DeviceConnection < EM::Connection
  attr_reader :device_id
  attr_reader :auth_token
  attr_reader :authenticated

  def post_init
    p "Connected #{Time.now}"

    @device_id = nil
    @auth_token = nil
    @authenticated = false
    @parser = MessageParser.new(self)
    @last_recv = Time.now

    DeviceManager.register self
    EM.add_periodic_timer(10) { tick }
  end
  
  def tick
    puts "Tick #{Time.now.sec - @last_recv.sec} ..."
    if (Time.now.sec - @last_recv.sec) > 15
      close_connection_after_writing
    end
    
    send_data [0].pack('N')
  end

  def unbind
    p "Closed #{Time.now}"

    @authenticated = false
    DeviceManager.unregister self
  end

  def receive_data( data )
    p "Data: #{data}"
    @last_recv = Time.now
    @parser.consume data
  end

  def dispatch_msg( payload )
    MessageHandler.handle self, payload
  end

  def device_id=(device_id)
    @device_id = device_id
  end

  def auth_token=(auth_token)
    @auth_token = auth_token
  end

  def authenticated=(authenticated)
    @authenticated = authenticated
  end
end
