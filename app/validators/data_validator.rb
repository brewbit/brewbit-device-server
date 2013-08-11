require 'crc'

class DataValidator

  def self.valid?( data )
    buffer_crc = get_crc_form_buffer data

    calculated_crc = calculate_crc data

    puts "Buffer CRC: #{buffer_crc}"
    puts "Calculated CRC: #{calculated_crc}"

    buffer_crc == calculated_crc
  end

  private

  def self.calculate_crc( data )
    buffer = data[3...-2] # grab everything up to the CRC
    Crc.crc16( buffer ).to_s(16)
  end

  def self.get_crc_form_buffer( data )
    crc = ''
    data[-2..-1].unpack( 'C*' ).each { |d| crc.insert 0, d.to_s(16) }

    crc
  end
end

