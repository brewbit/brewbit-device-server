class DeviceManager
  @@connections = []

  def self.find_all_by_device_id(device_id)
    @@connections.find_all { |c| c.device_id == device_id }
  end

  def self.register(connection)
    @@connections << connection
  end
  
  def self.unregister(connection)
    connection.close_connection
    @@connections.delete connection
  end

  def self.unregister_all(device_id)
    connections = find_all_by_device_id(device_id)
    connections.each do |connection|
      unregister connection
    end
  end
end
