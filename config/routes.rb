# frozen_string_literal: true

Rails.application.routes.draw do
  root 'books#index'

  scope :api do
    resources :books, except: :put
    resources :authors, except: :put
    resources :publishers, except: :put
    resources :users, except: :put

    resources :user_confirmations, only: :show, param: :confirmation_token
    resources :password_resets, only: %i[create show update], param: :reset_token
    get '/search/:text', to: 'search#index'
  end
end
