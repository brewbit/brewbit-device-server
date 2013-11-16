require 'spec_helper'
require 'binary_message_handler'

describe BinaryMessageHandler do

  before { @handler = BinaryMessageHandler.new }

  subject { @handler }

  describe 'process' do

    describe 'API message' do

      let( :bad_api_version ){ ApiMessage.new( api_version: 0xF, device_id: 0x1234578 ).to_binary_s }

      context 'with unsupported API version' do
        let( :message ){ FactoryGirl.build :api_version_message, data: bad_api_version, data_length: bad_api_version.length }

        before { @response = @handler.process message }

        it 'returns RESPONSE message with unsupported API version error' do
          @response.message_type.should eq Message::MESSAGE_TYPES[:response]
          @response.data.to_binary_s.should eq Message::ERROR_CODES[:api_version_not_supported].to_s
        end
      end

      context 'with supported API version' do
        let( :message ){ FactoryGirl.build :api_version_message }

        before { @response = @handler.process message }

        it 'returns RESPONSE message with success result' do
          @response.message_type.should eq Message::MESSAGE_TYPES[:response]
          @response.data.to_binary_s.should eq Message::ERROR_CODES[:success].to_s
        end
      end
    end

    describe 'Activation Token Request message' do
      let( :message ){ FactoryGirl.build :activation_token_request_message }
      let( :token ){ "6B1357" }

      before do
        allow_message_expectations_on_nil
        responder = @handler.responder
        responder.stub( :get_activation_token ){ "6B1357" }

        @response = @handler.process message
      end

      it 'returns the activation token' do
        @response.data.should eq token
      end
    end

    describe 'Authentication Token Request message' do
      let( :message ){ FactoryGirl.build :authentication_token_request_message }

      before { @response = @handler.process message }

      #it 'returns the authentication token' do
        #@response.data.should eq "kNf5UBtJpfRRUrq4zBLT"
      #end
    end
  end

  describe 'Device Status message' do
    let( :message ){ FactoryGirl.build :device_status_message }

    before { @response = @handler.process message }

    it 'returns RESPONSE message with SUCCESS value' do
      @response.message_type.should eq Message::MESSAGE_TYPES[:response]
      @response.data.should eq Message::ERROR_CODES[:success].to_s
    end
  end

  describe 'Device Settigs message' do
    let( :message ){ FactoryGirl.build :device_settings_message }

    before { @response = @handler.process message }

    it 'returns RESPONSE message with SUCCESS value' do
      @response.message_type.should eq Message::MESSAGE_TYPES[:response]
      @response.data.should eq Message::ERROR_CODES[:success].to_s
    end
  end
end

