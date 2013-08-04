require 'spec_helper'
require 'data_validator'

describe DataValidator do
  let( :valid_data ){ [0xb3, 0xeb, 0x17, 0x07, 0x82, 0x18].pack( 'C*' ) }
  let( :invalid_data ){ [0xb3, 0xeb, 0x17, 0x07, 0xFF, 0xff].pack( 'C*' ) }

  describe 'valid?' do
    context 'with valid data' do
      it 'returns true' do
        DataValidator.valid?( valid_data ).should be_true
      end
    end

    context 'with invalid data' do
      it 'returns false' do
        DataValidator.valid?( invalid_data ).should_not be_true
      end
    end
  end
end

