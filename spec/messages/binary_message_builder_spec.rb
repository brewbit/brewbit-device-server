require 'spec_helper'
require 'binary_message_builder'
require 'message'

describe BinaryMessageBuilder do

  describe 'ack message' do
    it 'is built with right data' do
      message = BinaryMessageBuilder.build Message::MESSAGE_TYPES[:ack], Message::ERROR_CODES[:success]
      message.message_type.should eq Message::MESSAGE_TYPES[:ack]
      message.data_length.should eq 1
      message.data.to_binary_s.should eq "0"
    end
  end
end

