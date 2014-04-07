require 'message_handler'

class DeviceManager
  attr_reader :connection
  attr_reader :device_id
  attr_reader :authenticated

  @@connections = []

  def self.all
    @@connections
  end

  def self.find_by_connection(connection)
    all.detect { |l| l.connection == connection }
  end

  def self.find_by_device_id(device_id)
    all.detect { |l| l.device_id == device_id }
  end

  def initialize(connection)
    @connection = connection
    @authenticated = false

    @buffer = ""
    @state = :length
    @bytes_remaining = 4

    @@connections << self

    p @@connections
  end

  def self.handle( connection, data )
    connection = DeviceManager.find_by_connection(connection)

    connection.process_data data if connection
  end

  def device
    Device.find_by hardware_identifier: @device_id
  end

  def delete
    @@connections.delete self
    @authenticated = false
    @connection = nil
  end

  def authenticate( auth_token )
    user = ApiKey.find_by_access_token( auth_token ).try( :user )

    if device and user and device.user == user
      @authenticated = true
    else
      false
    end
  end

  def process_data(data)
    while data.length > 0
      length = (data.length > @bytes_remaining ? @bytes_remaining : data.length)
      @buffer += data[0..length]
      @bytes_remaining -= length
      data = data[length..-1]

      if @bytes_remaining == 0
        if :length == @state
          @bytes_remaining = @buffer.unpack('N').first
          @state = :data
        elsif :data == @state
          @state = :length
          @bytes_remaining = 4

          MessageHandler.handle @connection, @buffer
        end
        @buffer = ""
      end
    end
  end
end
