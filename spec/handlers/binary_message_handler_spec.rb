require 'spec_helper'
require 'binary_message_handler'

describe BinaryMessageHandler do

  before { @handler = BinaryMessageHandler.new }

  subject { @handler }

  it { should respond_to :api_version }

  describe 'process' do

    describe 'API message' do
      context 'with unsupported API version' do
        let( :message ){ FactoryGirl.build :api_version_message, data: "123", data_length: 3 }

        before { @response = @handler.process message }

        it 'returns ACK message with unsupported API version error' do
          @response.message_type.should eq Message::MESSAGE_TYPES[:ack]
          @response.data.to_binary_s.should eq Message::ERROR_CODES[:api_version_not_supported].to_s
        end

        it 'does not update api version' do
          @handler.api_version.should_not eq message.data.to_binary_s
        end
      end

      context 'with supported API version' do
        let( :message ){ FactoryGirl.build :api_version_message }

        before { @response = @handler.process message }

        it 'returns ACK message with success result' do
          @response.message_type.should eq Message::MESSAGE_TYPES[:ack]
          @response.data.to_binary_s.should eq Message::ERROR_CODES[:success].to_s
        end

        it "updates the device's api version" do
          @handler.api_version.should eq message.data.to_binary_s
        end
      end
    end
  end
end

