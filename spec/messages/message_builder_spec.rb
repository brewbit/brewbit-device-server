require 'spec_helper'
require 'message_builder'

describe MessageBuilder do

  let( :ack ){ FactoryGirl.build :ack_message }
  let( :nack ){ FactoryGirl.build :nack_message }

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
end

