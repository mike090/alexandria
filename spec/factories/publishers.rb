# frozen_string_literal: true

FactoryBot.define do
  factory :publisher do
    name { "O'Reilly" }
  end

  factory :dev_media, class: 'Publisher' do
    name { 'Dev Media' }
  end

  factory :super_books, class: 'Publisher' do
    name { 'Super Books' }
  end

  factory :invalid_publisher_attributes, class: 'Publisher' do
    name { '' }
  end

  factory :error_publisher_attributes, class: 'Publisher' do
    name { "O'Reily" }
  end
end
