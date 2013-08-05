require 'spec_helper'
require 'temperature_profile_data'

describe TemperatureProfileData do

  before { @profile = TemperatureProfileData.new }

  subject { @profile }

  it { should respond_to :name_length }
  it { should respond_to :name }
  it { should respond_to :number_of_points }
  it { should respond_to :points }
end

