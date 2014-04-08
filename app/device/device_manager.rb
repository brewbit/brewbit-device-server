class DeviceManager
  attr_reader :connection
  attr_accessor :device_id, :auth_token, :authenticated

  @@connections = []

  def self.find_by_device_id(device_id)
    @@connections.detect { |l| l.device_id == device_id }
  end

  def initialize(connection)
    @connection = connection
    @authenticated = false
    @auth_token = nil

    @buffer = ""
    @state = :length
    @bytes_remaining = 4

    @@connections << self
  end

  def self.handle( connection, data )
    connection = DeviceManager.find_by_connection(connection)

    connection.process_data data if connection
  end

  def delete
    @@connections.delete self
    @authenticated = false
    @connection = nil
    @auth_token = nil
  end

  def send_message(data)
    @connection.send_message(data)
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

          MessageHandler.handle self, @buffer
        end
        @buffer = ""
      end
    end

  def register(connection)
    @@connections << connections
  end

  def unregister(connection)
    @@connections.delete connection
  end
end
