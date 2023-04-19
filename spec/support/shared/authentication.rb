# frozen_string_literal: true

shared_context 'authenticate client' do
  let(:api_key) { ApiKey.create }
  let(:headers) do
    { 'HTTP_AUTHORIZATION' => "Alexandria-Token api_key=#{api_key.id}:#{api_key.key}" }
  end
end

shared_context 'authenticate user' do |context_user|
  let(:user) { create(context_user || :user) }
  let(:api_key) { ApiKey.create }
  let(:access_token) { create(:access_token, user:, api_key:) }
  let(:headers) do
    token = access_token.generate_token
    { 'HTTP_AUTHORIZATION' => "Alexandria-Token api_key=#{api_key.id}:#{api_key.key} access_token=#{user.id}:#{token}" }
  end
end
