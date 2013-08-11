require 'message'

FactoryGirl.define do

  trait :start_message do
    sync1 179
    sync2 235
    sync3 23
  end

  factory :message do
    start_message

    after(:build) do |msg|
      msg.build_crc
    end

    factory :ack_message, class: Message do
      message_type  Message::MESSAGE_TYPES[:ack]
      data_length   0
      data          ''
    end

    factory :nack_message, class: Message do
      message_type  Message::MESSAGE_TYPES[:nack]
      data_length   0
      data          ''
    end

    factory :version_message, class: Message do
      message_type  Message::MESSAGE_TYPES[:version]
      data_length   1
      data          '1'
    end

    factory :temperature_message, class: Message do
      message_type  Message::MESSAGE_TYPES[:temperature]
      data_length   10
      data          "\x01\x14\xAE\xAAB" # Probe 1, Temp 85.34
    end

    factory :temp_profile_message, class: Message do
      message_type  Message::MESSAGE_TYPES[:temp_profile]
      data_length   85
      data          "\t\x00\x00\x00profile 1\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00\x00\xCD\xCC\x89B\x01\x00\x00\x00\x05\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x82B"
    end
  end
end

