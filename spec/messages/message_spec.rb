require 'spec_helper'
require 'message'

describe Message do

  let( :nack_message ){ FactoryGirl.build( :nack_message ).to_binary_s }
  let( :ack_message ){ FactoryGirl.build( :ack_message ).to_binary_s }
  let( :full_message ){ FactoryGirl.build( :temperature_message ).to_binary_s }

  before { @message = Message.new }

  subject { @message }

  it { should respond_to :start_message }
  it { should respond_to :message_type }
  it { should respond_to :data_length }
  it { should respond_to :data }
  it { should respond_to :crc }

  describe 'build_crc' do
    before do
      @message.message_type = Message::MESSAGE_TYPES[:version]
      @message.data_length = 11
      @message.data = 'abcabcabcav'
      @message.build_crc
    end

    it 'generates correct crc16' do
      expect( @message.crc ).to eq Crc.crc16( @message.to_binary_s[0...-2] )
    end
  end

  describe 'regular message' do
    before { @message.read full_message }

    it 'has data length defined' do
      expect( @message.data_length ).to eq FactoryGirl.build( :temperature_message ).data_length
    end

    it 'has data defined' do
      expect( @message.data ).to eq FactoryGirl.build( :temperature_message ).data.to_binary_s
    end
  end

  describe 'ack message' do
    before { @message.read ack_message }

    it 'has data length of 0' do
      expect( @message.data_length ).to eq 0
    end

    it 'has data set to be empty' do
      expect( @message.data ).to eq ""
    end
  end

  describe 'nack message' do
    before { @message.read nack_message }

    it 'has data length of 0' do
      expect( @message.data_length ).to eq 0
    end

    it 'has data set to be empty' do
      expect( @message.data ).to eq ""
    end
  end
end

