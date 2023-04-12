# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UserConfirmations' do
  describe 'GET /api/user_confirmations/:confirmation_token' do
    context 'with existing token' do
      before { get "/api/user_confirmations/#{john.confirmation_token}" }

      context 'with confirmation redirect url' do
        let(:john) { create(:user, :confirmation_redirect_url) }

        it 'redirects to http://google.com' do
          expect(response).to redirect_to('http://google.com')
        end
      end

      context 'without confirmation redirect url' do
        let(:john) { create(:user, :confirmation_no_redirect_url) }

        it 'returns success confirmation message' do
          expect(response).to have_http_status :ok
          expect(response.body).to eq 'You are now conformated!'
        end
      end
    end

    context 'with nonexistent token' do
      before { get '/api/user_confirmations/fake' }

      it 'returns "Token not found"' do
        expect(response).to have_http_status :not_found
        expect(response.body).to eq 'Token not found'
      end
    end
  end
end
