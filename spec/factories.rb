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
      data_length   1
      data          "1"
    end
  end
end

