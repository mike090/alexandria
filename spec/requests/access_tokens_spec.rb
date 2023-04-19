# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Access Tokens' do
  let(:john) { create(:user) }
  let(:params) { { data: { email:, password: } } }

  describe 'POST /api/access_tokens' do
    context 'with valid API key' do
      let(:api_key) { ApiKey.create }
      let(:headers) { { 'HTTP_AUTHORIZATION' => "Alexandria-Token api_key=#{api_key.id}:#{api_key.key}" } }

      before { post '/api/access_tokens', params:, headers: }

      context 'with existing user' do
        let(:email) { john.email }

        context 'with valid password' do
          let(:password) { 'password' }

          it 'returns access tokens and user' do
            expect(response).to have_http_status :created
            expect(json_body['data']['token']).not_to be_nil
            expect(json_body['data']['user']['id']).to eq john.id
          end
        end

        context 'with invalid password' do
          let(:password) { 'fake' }

          it 'returns HTTP status 422' do
            expect(response).to have_http_status :unprocessable_entity
          end
        end
      end

      context 'with nonexistent user' do
        let(:email) { 'unknown' }
        let(:password) { 'fake' }

        it 'returns HTTP status 404' do
          expect(response).to have_http_status :not_found
        end
      end
    end

    context 'with invalid API key' do
      let(:email) { john.email }
      let(:password) { 'password' }

      it 'returns HTTP status 401' do
        post('/api/access_tokens', params:)
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'DELETE /api/access_tokens' do
    let(:headers) { { 'HTTP_AUTHORIZATION' => "Alexandria-Token api_key=#{api_key_str} access_token=#{token_str}" } }

    before { delete '/api/access_tokens', headers: }

    context 'with valid API key' do
      let(:api_key) { ApiKey.create }
      let(:api_key_str) { "#{api_key.id}:#{api_key.key}" }

      context 'with valid access token' do
        let(:access_token) { create(:access_token, api_key:, user: john) }
        let(:token) { access_token.generate_token }
        let(:token_str) { "#{john.id}:#{token}" }

        it 'destroys the access token' do
          expect(response).to have_http_status :no_content
          expect(john.reload.access_tokens.size).to eq 0
        end
      end

      context 'with invalid access token' do
        let(:token_str) { '1:fake' }

        it 'returns HTTP status 401' do
          expect(response).to have_http_status :unauthorized
        end
      end
    end

    context 'with invalid API key' do
      let(:api_key) { ApiKey.create }
      let(:api_key_str) { '1:fake' }
      let(:access_token) { create(:access_token, api_key:, user: john) }
      let(:token) { access_token.generate_token }
      let(:token_str) { "#{john.id}:#{token}" }

      it 'returns HTTP status 401' do
        expect(response).to have_http_status :unauthorized
      end
    end
  end
end
