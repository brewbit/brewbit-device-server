require 'device_manager'
require 'message_parser'
require 'message_handler'

class DeviceConnection < EM::Connection
  attr_accessor :device_id
  attr_accessor :auth_token
  attr_accessor :authenticated

  def post_init
    Log.debug "Connected #{Time.now}"

    @device_id = nil
    @auth_token = nil
    @authenticated = false
    @parser = MessageParser.new(self)
    @last_recv = Time.now

    DeviceManager.register self
    @timer = EM.add_periodic_timer(10) { tick }
  end

  def tick
    time_since_last_recv = Time.now.to_i - @last_recv.to_i
    Log.debug "Tick #{time_since_last_recv} ..."
    if (time_since_last_recv) > 15
      close_connection
    else
      # send keepalive
      send_data [0].pack('N')
    end
  end

  def unbind
    Log.debug "Closed #{Time.now}"

    @timer.cancel
    @authenticated = false
    DeviceManager.unregister self
  end

  def receive_data( data )
    Log.debug "Data: #{data.inspect}"
    @last_recv = Time.now
    @parser.consume data
  end

  def dispatch_msg( payload )
    MessageHandler.handle self, payload
  end
end
