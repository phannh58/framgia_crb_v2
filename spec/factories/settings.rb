require "ffaker"

FactoryGirl.define do
  factory :setting do
    timezone_name {FFaker::Address.time_zone}
  end
end
