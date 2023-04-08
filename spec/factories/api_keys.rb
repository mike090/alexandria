# frozen_string_literal: true

FactoryBot.define do
  factory :api_key do
    key { 'RandomKey' }
    active { true }
  end
end
