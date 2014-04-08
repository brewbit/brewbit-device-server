class DeviceManager
  @@connections = []

  def self.find_by_device_id(device_id)
    @@connections.detect { |l| l.device_id == device_id }
  end

  def register(connection)
    @@connections << connections
  end
  
  def unregister(connection)
    @@connections.delete connection
  end
end
