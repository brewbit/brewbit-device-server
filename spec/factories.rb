require 'message'

FactoryGirl.define do
  trait :start_message do
    start_message 11791127
  end

  factory :ack_message, class: Message do
    start_message
    message_type  Message::MESSAGE_TYPES[:ack]
    data_length   0
    data          ''
    crc           17113
  end

  factory :nack_message, class: Message do
    start_message
    message_type  Message::MESSAGE_TYPES[:nack]
    data_length   0
    data          ''
    crc           33304
  end

  factory :version_message, class: Message do
    start_message
    message_type  Message::MESSAGE_TYPES[:version]
    data_length   1
    data          '1'
    crc           35273
  end

  factory :temperature_message, class: Message do
    start_message
    message_type  Message::MESSAGE_TYPES[:temperature]
    data_length   8
    data          'Nb\x10X9l{@' # 438.764
    crc           33766
  end

end

