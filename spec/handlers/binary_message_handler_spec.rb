require 'spec_helper'
require 'binary_message_handler'
require 'eventmachine'
require 'model_t_server'

describe BinaryMessageHandler do

  before do
    @device = ModelTServer.new( 1 )
    @device.id = 0x12345678
    @device.api_version = 1
    @device.authentication_token = 'kNf5UBtJpfRRUrq4zBLT'
    @activation_token = '12345678'
    @httparty_response = double('httparty response')

    @handler = BinaryMessageHandler.new @device
  end

  subject { @handler }

  describe 'process' do

    describe 'Bad CRC message' do
      let( :message ){ FactoryGirl.build :api_version_message }

      before { message.crc = 30454 }

      it 'returns RESPONSE message with BAD CRC' do
        response = @handler.process( message.to_binary_s )
        response.message_type.should eq Message::MESSAGE_TYPES[:response]
        response.data.to_binary_s.should eq Message::ERROR_CODES[:crc_failed].to_s
      end
    end

    describe 'API message' do
      let( :bad_api_version ){ ApiMessage.new( api_version: 0xF, device_id: 0x1234578 ).to_binary_s }

      context 'with unsupported API version' do
        let( :message ){ FactoryGirl.build :api_version_message, data: bad_api_version, data_length: bad_api_version.length }

        before { @response = @handler.process( message.to_binary_s ) }

        it 'returns RESPONSE message with unsupported API version error' do
          @response.message_type.should eq Message::MESSAGE_TYPES[:response]
          @response.data.to_binary_s.should eq Message::ERROR_CODES[:api_version_not_supported].to_s
        end
      end

      context 'with supported API version' do
        let( :message ){ FactoryGirl.build :api_version_message }

        before { @response = @handler.process( message.to_binary_s ) }

        it 'returns RESPONSE message with success result' do
          @response.message_type.should eq Message::MESSAGE_TYPES[:response]
          @response.data.to_binary_s.should eq Message::ERROR_CODES[:success].to_s
        end
      end
    end

    describe 'Activation Token Request message' do

      let( :message ){ FactoryGirl.build :activation_token_request_message }

      context 'successful result' do
        before do
          @httparty_response.stub( :body ){ "{ \"activation_token\": \"#{@activation_token}\" }" }
          @httparty_response.stub( :code ){ 200 }
          HTTParty.should_receive( :get ).and_return( @httparty_response )

          @response = @handler.process( message.to_binary_s )
        end

        it 'returns the activation token' do
          @response.data.should eq @activation_token
        end
      end

      context 'when activation token is not found' do
        before do
          @httparty_response.stub( :body ){ '{ "activation_token": "" }' }
          @httparty_response.stub( :code ){ 404 }
          HTTParty.should_receive( :get ).and_return( @httparty_response )

          @response = @handler.process( message.to_binary_s )
        end

        it 'returns the error message' do
          @response.message_type.should eq Message::MESSAGE_TYPES[:response]
          @response.data.should eq Message::ERROR_CODES[:failed_to_get_activation_token].to_s
        end
      end
    end

    describe 'Authentication Token Request message' do
      let( :message ){ FactoryGirl.build :authentication_token_request_message }

      context 'with good activation token' do
        before do
          @httparty_response.stub( :body ){ "{ \"auth_token\": \"#{@device.authentication_token}\" }" }
          @httparty_response.stub( :code ){ 200 }
          HTTParty.should_receive( :post ).and_return( @httparty_response )

          @response = @handler.process( message.to_binary_s )
        end

        it 'returns the authentication token' do
          @response.data.should eq @device.authentication_token
        end
      end

      context 'with bad activation token' do
        before do
          @httparty_response.stub( :body ){ '{ "auth_token": "" }' }
          @httparty_response.stub( :code ){ 404 }
          HTTParty.should_receive( :post ).and_return( @httparty_response )

          @response = @handler.process( message.to_binary_s )
        end

        it 'returns the error message' do
          @response.message_type.should eq Message::MESSAGE_TYPES[:response]
          @response.data.should eq Message::ERROR_CODES[:activation_token_not_found].to_s
        end
      end
    end

    describe 'Device Status message' do
      let( :message ){ FactoryGirl.build :device_status_message }

      before do
        @httparty_response = Net::HTTPCreated.new( 1, '201', 'Created' )
        HTTParty.should_receive( :post ).and_return( @httparty_response )

        @response = @handler.process( message.to_binary_s )
      end

      it 'returns RESPONSE message with SUCCESS value' do
        @response.message_type.should eq Message::MESSAGE_TYPES[:response]
        @response.data.should eq Message::ERROR_CODES[:success].to_s
      end
    end

    describe 'Device Settigs message' do
      let( :message ){ FactoryGirl.build :device_settings_message }

      before do
        @httparty_response = Net::HTTPCreated.new( 1, '201', 'Created' )
        HTTParty.should_receive( :post ).and_return( @httparty_response )
        @response = @handler.process( message.to_binary_s )
      end

      it 'returns RESPONSE message with SUCCESS value' do
        @response.message_type.should eq Message::MESSAGE_TYPES[:response]
        @response.data.should eq Message::ERROR_CODES[:success].to_s
      end
    end

    describe 'Authenticate message' do
      let( :message ){ FactoryGirl.build :authentication_request_message }

      context 'with good authentication token' do
        before do
          @httparty_response.stub( :code ){ 200 }
          HTTParty.should_receive( :post ).and_return( @httparty_response )
          @response = @handler.process( message.to_binary_s )
        end

        it 'return RESPONSE message with AUTHENTICATION SUCCESSFUL value' do
          @response.message_type.should eq Message::MESSAGE_TYPES[:response]
          @response.data.should eq Message::ERROR_CODES[:authentication_successful].to_s
        end
      end

      context 'with bad authentication token' do
        before do
          @httparty_response.stub( :code ){ 401 }
          HTTParty.should_receive( :post ).and_return( @httparty_response )
          @response = @handler.process( message.to_binary_s )
        end

        it 'return RESPONSE message with BAD AUTHENTICATION TOKEN value' do
          @response.message_type.should eq Message::MESSAGE_TYPES[:response]
          @response.data.should eq Message::ERROR_CODES[:bad_authentication_token].to_s
        end
      end
    end
  end
end

