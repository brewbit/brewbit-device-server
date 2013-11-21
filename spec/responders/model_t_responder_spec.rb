require 'spec_helper'
require 'model_t_responder'
require 'eventmachine'
require 'model_t_server'

describe ModelTResponder do

  before do
    @device = ModelTServer.new( 1 )
    @device.id = 0x12345678
    @device.api_version = 1
    @device.authentication_token = 'kNf5UBtJpfRRUrq4zBLT'
    @activation_token = '123456'
    @api_url = "#{ModelTResponder::BREWBIT_API_URL}/v#{@device.api_version}"

    @responder = ModelTResponder.new( @device )
  end

  subject { @responder }

  before do
    @httparty_response = double('httparty response')
  end

  context 'get_activation_token' do
    context 'received successfully' do
      before do
        @httparty_response.stub( :body ){ "{ \"activation_token\": \"#{@activation_token}\" }" }
        @httparty_response.stub( :code ){ 200 }
      end

      it 'returns the activation token' do
        HTTParty.should_receive( :get )
          .with( "#{@api_url}/activation/new.json",
                 query: { device_id: @device.id } )
          .and_return( @httparty_response )

        @responder.get_activation_token.should eq @activation_token
      end
    end

    context 'bad response' do
      context 'with bad HTTP status code' do
        before do
          @httparty_response.stub( :body ){ "{ \"activation_token\": \"#{@activation_token}\" }" }
          @httparty_response.stub( :code ){ 404 }
        end

        it 'raises an error' do
          HTTParty.should_receive( :get ).and_return( @httparty_response )

          expect{ @responder.get_activation_token }.to raise_error( ModelTResponder::FailedToGetActivationToken )
        end
      end

      context 'with empty activation token' do
        before do
          @httparty_response.stub( :body ){ '{ "activation_token": "" }' }
          @httparty_response.stub( :code ){ 200 }
        end

        it 'raises an error' do
          HTTParty.should_receive( :get ).and_return( @httparty_response )

          expect{ @responder.get_activation_token }.to raise_error( ModelTResponder::FailedToGetActivationToken )
        end
      end
    end
  end

  context 'get_authentication_token' do
    context 'successfully' do
      before do
        @httparty_response.stub( :body ){ "{ \"auth_token\": \"#{@device.authentication_token}\" }" }
        @httparty_response.stub( :code ){ 200 }
      end

      it 'returns the authentication token' do
        HTTParty.should_receive( :post )
          .with( "#{@api_url}/activation",
                 query: { device_id: @device.id, activation_token: @activation_token } )
          .and_return( @httparty_response )

        @responder.get_authentication_token( @activation_token ).should eq @device.authentication_token
      end
    end

    context 'with errors' do
      context 'bad activation token' do
        before do
          @httparty_response.stub( :body ){ '{ "auth_token": "" }' }
          @httparty_response.stub( :code ){ 404 }
        end

        it 'raises an error' do
          HTTParty.should_receive( :post ).and_return( @httparty_response )

          expect{ @responder.get_authentication_token( @activation_token ) }.to raise_error( ModelTResponder::ActivationTokenNotFound )
        end
      end
    end
  end

  context 'authenticate' do
    context 'successfully' do
      before do
        @httparty_response.stub( :code ){ 200 }
      end

      it 'successfully authenticates the device' do
        HTTParty.should_receive( :post )
          .with( "#{@api_url}/account/authenticate",
                 query: { device_id: @device.id, authentication_token: @device.authentication_token } )
          .and_return( @httparty_response )

        @responder.authenticate( @device.authentication_token ).should be_true
      end
    end

    context 'with errors' do
      before do
        @httparty_response.stub( :code ){ 401 }
      end

      it 'raisese an error' do
        HTTParty.should_receive( :post ).and_return( @httparty_response )

        expect{ @responder.authenticate( @device.authentication_token ) }.to raise_error( ModelTResponder::AuthenticationTokenNotFound )
      end
    end
  end

  context 'set_device_status' do
    before do
      @status = {
        timestamp:      '1095379198',
        wifi_strength:  50,
        probes: [
          {
            id:          1,
            temperature: 56
          },
          {
            id:          2,
            temperature: 32
          }
        ]
      }
      @httparty_response = Net::HTTPCreated.new( 1, '201', 'Created' )
    end

    it 'successfully updates device status' do
      HTTParty.should_receive( :post )
        .with( "#{@api_url}/devices/#{@device.id}",
               query: { authentication_token: @device.authentication_token, device: @status } )
        .and_return( @httparty_response )

      @responder.set_device_status( @status, @device.authentication_token ).should be_true
    end
  end

  context 'set_device_settings' do
    before do
      @settings = {
        timestamp:          '1095379198',
        device_name:        'Test Device',
        temperature_scale:  'F',
        outputs: [
          {
            function: 'hot',
            trigger: 1,
            setpoint: 75,
            compressor_delay: 8,
          },
          {
            function: 'cold',
            trigger: 2,
            setpoint: 24,
            compressor_delay: 3
          }
        ]
      }
      @httparty_response = Net::HTTPCreated.new( 1, '201', 'Created' )
    end

    it 'successfully updates device settings' do
      HTTParty.should_receive( :post )
        .with( "#{@api_url}/devices/#{@device.id}",
               query: { authentication_token: @device.authentication_token, device: @settings } )
        .and_return( @httparty_response )

      @responder.update_device_settings( @settings, @device.authentication_token ).should be_true
    end
  end
end

