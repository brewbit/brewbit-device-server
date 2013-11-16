require 'spec_helper'
require 'device_status_message'

describe DeviceStatusMessage do

  before { @device_status = DeviceStatusMessage.new }

  subject { @device_status }

  it { should respond_to :timestamp }
  it { should respond_to :status }
end

