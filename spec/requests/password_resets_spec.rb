# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PasswordResets' do
  describe 'POST /api/passwords_resets' do
    let(:user) { create(:user) }

    include_context 'authentication'

    before { post '/api/password_resets', params:, headers: }

    context 'with walid parameters' do
      let(:params) do
        {
          data: {
            email: user.email,
            reset_password_redirect_url: 'example.com'
          }
        }
      end

      it 'sends the reset pasword email and adds reset password attributes to user' do
        expect(response).to have_http_status :no_content

        expect(ActionMailer::Base.deliveries.last.subject).to eq 'Reset your password'

        expect(user.reset_password_token).to be_nil
        expect(user.reset_password_sent_at).to be_nil
        updated = user.reload
        expect(updated.reset_password_token).not_to be_nil
        expect(updated.reset_password_sent_at).not_to be_nil
        expect(updated.reset_password_redirect_url).to eq params[:data][:reset_password_redirect_url]
      end
    end

    context 'with invalid parameters' do
      let(:params) { { data: { email: user.email } } }

      it 'returns HTTP status 422' do
        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context 'with nonexistent user' do
      let(:params) { { data: { email: 'fake@example.com' } } }

      it 'returns HTTP status 404' do
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'GET /api/passwords_resets/:reset_token' do
    let(:token) { user.reset_password_token }

    before do
      user
      get "/api/password_resets/#{token}"
    end

    context 'with existing user (token is valid)' do
      context 'when redirect URL contains parameters' do
        let(:user) { create(:user, :reset_password) }

        it 'redirects to URL with parameters' do
          expect(response).to redirect_to "#{user.reset_password_redirect_url}&reset_token=#{token}"
        end
      end

      context 'when redirect URL not contains any parameters' do
        let(:user) { create(:user, :reset_password_no_params) }

        it 'redirects to URL without parameters' do
          expect(response).to redirect_to "#{user.reset_password_redirect_url}?reset_token=#{token}"
        end
      end
    end

    context 'with nonexistent user' do
      let(:user) { create(:user) }
      let(:token) { '123' }

      it 'returns HTTP status 404' do
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'PATCH /api/passwords_resets/:reset_token' do
    let(:params) { { data: { password: 'new_password' } } }

    before do
      user
      patch "/api/password_resets/#{token}", params:, headers:
    end

    include_context 'authentication'

    context 'with existing user (token is valid)' do
      let(:user) { create(:user, :reset_password) }
      let(:token) { user.reset_password_token }

      context 'when parameters are valid' do
        it 'updates the password' do
          expect(response).to have_http_status :no_content
          expect(user.reload.authenticate('new_password')).not_to be_nil
        end
      end

      context 'when parameters are invalid' do
        let(:params) { { data: { password: '' } } }

        it 'returns HTTP status 422' do
          expect(response).to have_http_status :unprocessable_entity
        end
      end
    end

    context 'with nonexistent user' do
      let(:user) { create(:user) }
      let(:token) { '123' }

      it 'returns HTTP status 404' do
        expect(response).to have_http_status :not_found
      end
    end
  end
end
