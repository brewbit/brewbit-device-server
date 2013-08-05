require 'spec_helper'
require 'message_builder'

describe MessageBuilder do

  let( :ack ){ FactoryGirl.build :ack_message }
  let( :nack ){ FactoryGirl.build :nack_message }
  let( :temp_profile ){ FactoryGirl.build :temp_profile_message }

  describe 'ack message' do
    it 'is built' do
      message = MessageBuilder.build Message::MESSAGE_TYPES[:ack]
      expect( message ).to eq ack
    end
  end

  describe 'nack message' do
    it 'is built' do
      message = MessageBuilder.build Message::MESSAGE_TYPES[:nack]
      expect( message ).to eq nack
    end
  end

  describe 'temperature profile' do
    let( :data ){ '{ "name": "profile 1", "temperature_points": [{"index": 0, "temperature": 68.9, "duration": 3, "transition": "gradual" }, {"index": 1, "temperature": 65.0, "duration": 5, "transition": "gradual"}] }' }

    it 'is built' do
      message = MessageBuilder.build( Message::MESSAGE_TYPES[:temp_profile], data )
      expect( message ).to eq temp_profile
    end
  end
end

