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

    DeviceManager.register self
  end

  def unbind
    p "Closed #{Time.now}"

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
