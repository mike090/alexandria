# frozen_string_literal: true

FactoryBot.define do
  factory :access_token do
    token_digest { nil }
    accessed_at { '2023-04-12 23:17:54' }
    user
    api_key
  end
end
