require 'spec_helper'
require 'api_message'

describe ApiMessage do

  let( :data ){ [ 0x1, 0x1234 ].pack 'CQ' }
  let( :invalid_api_version_data ){ [0xF, 0x1234 ].pack 'CQ' }

  before { @message = ApiMessage.new }

  subject { @message }

  it { should respond_to :api_version }
  it { should respond_to :device_id }

  context 'api_version' do
    before { @message.read data }
    it { @message.api_version.should eq 0x1 }
  end

  context 'device_id' do
    before { @message.read data }
    it { @message.device_id.should eq 0x1234 }
  end

  context 'process' do
    context 'invalid API version' do
      before { @message.read invalid_api_version_data }
      it 'returns with API NOT SUPPORTED code' do
        @message.process.should eq Message::ERROR_CODES[:api_version_not_supported]
      end
    end

    context 'valid API version' do
      before { @message.read data }
      it 'returns SUCCESS code' do
        @message.process.should eq Message::ERROR_CODES[:success]
      end
    end
  end
end

