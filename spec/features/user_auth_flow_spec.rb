# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Auth Flow', type: :request do
  def headers(user_id = nil, token = nil)
    api_key_str = "api_key=#{api_key.id}:#{api_key.key}"
    token_str = user_id && token ? "access_token=#{user_id}:#{token}" : ''
    { 'HTTP_AUTHORIZATION' => "Alexandria-Token #{api_key_str} #{token_str}" }
  end

  let(:api_key) { ApiKey.create }
  let(:email) { 'john@gmail.com' }
  let(:password) { 'password' }
  let(:params) { { email:, password:, given_name: 'Johnny' } }

  it 'authenticate a new user' do
    # 1 - Create a user
    post('/api/users', params: { data: params }, headers:)
    expect(response).to have_http_status :created
    id = json_body['data']['id']

    # 2 - Try to update given name
    patch("/api/users/#{id}", params: { data: { given_name: 'John' } }, headers:)
    expect(response).to have_http_status :unauthorized

    # 3 - Login
    post('/api/access_tokens', params: { data: { email:, password: } }, headers:)
    expect(response).to have_http_status :created
    expect(json_body['data']['token']).not_to be_nil
    expect(json_body['data']['user']['email']).to eq email
    token = json_body['data']['token']
    user_id = json_body['data']['user']['id']

    # 4 - Update given name
    patch("/api/users/#{user_id}", params: { data: { given_name: 'John' } }, headers: headers(user_id, token))
    expect(response).to have_http_status :ok
    expect(json_body['data']['given_name']).to eq 'John'
    expect(User.find(user_id).given_name).to eq 'John'

    # 5 - Try to list all users
    get('/api/users', headers: headers(user_id, token))
    expect(response).to have_http_status :forbidden

    # 6 - Logout
    delete('/api/access_tokens', headers: headers(user_id, token))
    expect(response).to have_http_status :no_content

    # 7 - Try to access user info with invalid token
    get("/api/users/#{user_id}", headers: headers(user_id, token))
    expect(response).to have_http_status :unauthorized
  end
end
