require 'spec_helper'
require 'temperature_data'

describe TemperatureData do

  let( :data ){ [ 1, 85.34 ].pack 'Cf' }

  before { @temp_data = TemperatureData.new }

  subject { @temp_data }

  it { should respond_to :probe }
  it { should respond_to :temperature }

  context 'probe' do
    before { @temp_data.read data }
    it { @temp_data.probe.should eq 1 }
  end

  context 'temperature' do
    before { @temp_data.read data }
    it { @temp_data.temperature.round(2).should eq 85.34 }
  end
end

