# frozen_string_literal: true

Rails.application.routes.draw do
  root 'books#index'

  scope :api do
    resources :books
    resources :authors
    resources :publishers
  end
end
