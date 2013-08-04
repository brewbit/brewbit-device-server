require 'spec_helper'
require 'message'

describe Message do

  let( :nack_message ){ [0xb3, 0xeb, 0x17, 0x07, 0xFF, 0xff].pack( 'c*' ) }
  let( :ack_message ){ [0xb3, 0xeb, 0x17, 0x06, 0xFF, 0xff].pack( 'c*' ) }
  let( :full_message ){ [0xb3, 0xeb, 0x17, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x01, 0x02, 0xd0, 0x47].pack( 'c*' ) }

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
      expect( @message.crc ).to eq 45998
    end
  end

  describe 'regular message' do
    before { @message.read full_message }

    it 'has data length defined' do
      expect( @message.data_length ).to eq 0x03
    end

    it 'has data defined' do
      expect( @message.data ).to eq [0x00, 0x01, 0x02].pack( 'c*' )
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

