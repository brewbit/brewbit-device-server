module ProtobufMessages::Sender

  def self.send( message, connection )
    # TODO schedule in background worker
    send_message message, connection
  end

  private

  def self.serialize_message( message )
    # TODO: Add 4 bytes with message length to message

    msg = message.encode.to_s

    length = [msg.size].pack('N')

    wrapped_message = length + msg

    wrapped_message.unpack('c*')
  end

  def self.send_message( message, connection )
    data = serialize_message( message )

    p 'Sending Message'
    p "    Message: #{message.inspect}"
    p "    Data: #{data}"

    # TODO use mutex to lock use of socket?
    connection.send_message data
  end
end

