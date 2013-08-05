require 'message'

FactoryGirl.define do

  trait :start_message do
    start_message 11791127
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
  end
end

