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

    factory :api_version_message, class: Message do
      message_type  Message::MESSAGE_TYPES[:api_version]
      data_length   9
      data          "\x01\xFB4\x12\x00\x00\x00\x00\x00"
    end

    factory :activation_token_request_message, class: Message do
      message_type Message::MESSAGE_TYPES[:activation_token_request]
      data_length 0
    end

    factory :activation_token_response_message, class: Message do
      message_type Message::MESSAGE_TYPES[:activation_token_response]
      data_length  6
      data         "\x00\x00\x00\x00\x00\x80"
    end

    factory :authentication_token_request_message, class: Message do
      message_type Message::MESSAGE_TYPES[:authentication_token_request]
      data_length "kNf5UBtJpfRRUrq4zBLT".length
      data        "kNf5UBtJpfRRUrq4zBLT"
    end

    factory :device_status_message, class: Message do
      message_type Message::MESSAGE_TYPES[:device_status]
      data_length "P\x00\x00\x00\x02\x00\x00\x008\x00\x00\x00N\x00\x00\x00".length
      data        "P\x00\x00\x00\x02\x00\x00\x008\x00\x00\x00N\x00\x00\x00"
    end

    factory :device_settings_message, class: Message do
      message_type Message::MESSAGE_TYPES[:device_settings]
      data_length 0
      data        ""
    end
  end
end

