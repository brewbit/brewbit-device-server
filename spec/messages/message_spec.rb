require 'spec_helper'
require 'message'
require 'bindata'

class TestData < BinData::Record
  endian ENDIAN
  uint8   :point1
  uint16  :point2
end

describe Message do

  before do
    t = TestData.new
    t.point1 = 15
    t.point2 = 32

    @message = Message.new
    @message.message_type = Message::MESSAGE_TYPES[:response]
    @message.data_length = 10
    @message.data = t.to_binary_s
  end

  subject { @message }

  it { should respond_to :sync1 }
  it { should respond_to :sync2 }
  it { should respond_to :sync3 }
  it { should respond_to :message_type }
  it { should respond_to :data_length }
  it { should respond_to :data }
  it { should respond_to :crc }
  it { should respond_to :valid? }
  it { should respond_to :build_crc }
  it { should respond_to :has_data? }

  describe 'build_crc' do
    before do
      @message.build_crc
    end

    it 'stores CRC16 in crc field' do
      @message.crc.should eq 64419
    end
  end

  describe 'valid?' do
    context 'for good crc is true' do
      before do
        @message.build_crc
      end

      it { should be_valid }
    end

    context 'for bad crc is false' do
      before do
        @message.crc = 1111
      end

      it { should_not be_valid }
    end
  end

  describe 'has_data?' do
    context 'with data length not 0 and data not empty' do
      it 'returns true' do
        @message.has_data?.should be_true
      end
    end

    context 'with data length 0' do
      before { @message.data_length = 0 }

      it 'returns false' do
        @message.has_data?.should be_false
      end
    end
  end
end

