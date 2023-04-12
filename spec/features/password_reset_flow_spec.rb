# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Password Reset Flow', type: :request do
  let(:john) { create(:user) }
  let(:create_params) do
    { email: john.email, reset_password_redirect_url: 'http://www.example.com' }
  end
  let(:update_params) { { password: 'new_password' } }

  include_context 'authentication'

  it 'resets the password' do
    expect(john.authenticate('password')).not_to be false
    expect(john.reset_password_token).to be_nil

    post('/api/password_resets', params: { data: create_params }, headers:)
    expect(response).to have_http_status :no_content
    reset_token = john.reload.reset_password_token
    expect(ActionMailer::Base.deliveries.last.body).to match reset_token

    get "/api/password_resets/#{reset_token}"
    expect(response).to redirect_to "http://www.example.com?reset_token=#{reset_token}"

    patch("/api/password_resets/#{reset_token}", params: { data: update_params }, headers:)
    expect(response).to have_http_status :no_content
    expect(john.reload.authenticate('new_password')).not_to be false
  end
end
