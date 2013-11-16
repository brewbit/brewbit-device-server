require 'spec_helper'
require 'model_t_responder'

describe ModelTResponder do

  before do
    @device_id = '123'
    @api_version = 1
    @api_url = "#{ModelTResponder::BREWBIT_API_URL}/v#{@api_version}"
    @activation_token = '123456'

    @responder = ModelTResponder.new
    @responder.device_id = @device_id
    @responder.api_version = @api_version
  end

  subject { @responder }

  it { should respond_to :api_version }
  it { should respond_to :device_id }

  before do
    @httparty_response = double('httparty response')
  end

  context 'get_activation_token' do
    before do
      @httparty_response.stub( :body ) { "{ \"activation_token\": \"#{@activation_token}\" }" }
    end

    it 'returns the activation token' do
      HTTParty.should_receive( :get )
        .with( "#{@api_url}/activation/new.json",
               query: { device_id: @device_id } )
        .and_return( @httparty_response )

      @responder.get_activation_token.should eq @activation_token
    end
  end

  context 'get_authentication_token' do
    before do
      @auth_token = 'kNf5UBtJpfRRUrq4zBLT'
      @httparty_response.stub( :body ) { "{ \"auth_token\": \"#{@auth_token}\" }" }
    end

    it 'returns the authentication token' do
      HTTParty.should_receive( :post )
        .with( "#{@api_url}/activation.json",
               query: { device_id: @device_id, activation_token: @activation_token } )
        .and_return( @httparty_response )

      @responder.get_authentication_token( @activation_token ).should eq @auth_token
    end
  end
end

