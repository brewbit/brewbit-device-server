require 'spec_helper'
require 'binary_message_builder'
require 'message'

describe BinaryMessageBuilder do

  describe 'response message' do
    before { @message = BinaryMessageBuilder.build Message::MESSAGE_TYPES[:response], Message::ERROR_CODES[:success] }

    it 'is built with right data' do
      @message.message_type.should eq Message::MESSAGE_TYPES[:response]
      @message.data_length.should eq 1
      @message.data.to_binary_s.should eq "0"
    end
  end

  describe 'activation_token_response message' do
    let( :token ){ 0x800000000000 }

    before { @message = BinaryMessageBuilder.build Message::MESSAGE_TYPES[:activation_token_response], token }

    it 'is built with right data' do
      @message.message_type.should eq Message::MESSAGE_TYPES[:activation_token_response]
      @message.data_length.should eq "#{token}".length
      @message.data.should eq token.to_s
    end
  end

  describe 'authentication_token_response message' do
    let( :token ){ "kNf5UBtJpfRRUrq4zBLT" }

    before { @message = BinaryMessageBuilder.build Message::MESSAGE_TYPES[:authentication_token_response], token }

    it 'is built with the right data' do
      @message.message_type.should eq Message::MESSAGE_TYPES[:authentication_token_response]
      @message.data_length.should eq token.length
      @message.data.should eq token
    end
  end
end

