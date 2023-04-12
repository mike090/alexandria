# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { 'john@example.com' }
    password { 'password' }
    given_name { 'John' }
    family_name { 'Doe' }
    role { :user }

    trait :confirmation_redirect_url do
      confirmation_token { '123' }
      confirmation_redirect_url { 'http://google.com' }
    end

    trait :confirmation_no_redirect_url do
      confirmation_token { '123' }
      confirmation_redirect_url { nil }
    end

    trait :reset_password do
      reset_password_token { '123' }
      reset_password_redirect_url { 'http://www.example.com?some=params' }
      reset_password_sent_at { Time.now }
    end

    trait :reset_password_no_params do
      reset_password_token { '123' }
      reset_password_redirect_url { 'http://www.example.com' }
      reset_password_sent_at { Time.now }
    end
  end

  factory :invalid_user_attributes, class: 'User' do
    email { 'john.example.com' }
  end

  factory :error_user_attributes, class: 'User' do
    email { 'kate@example.com' }
  end
end
