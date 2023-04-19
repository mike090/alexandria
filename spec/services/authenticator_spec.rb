# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Authenticator do
  # describe '#api_key' do
  #   subject(:instance) { described_class.new(authorization_str) }

  #   let(:api_key) { create(:api_key) }

  #   context 'with valid authorization data' do
  #     let(:authorization_str) { "Alexandria-Token api_key=#{api_key.id}:#{api_key.key}" }

  #     it 'returns api key' do
  #       expect(instance.api_key).to eq api_key
  #     end
  #   end

  #   context 'with invalid authorization data' do
  #     let(:authorization_str) { "Alexandria-Token api_key=100:#{api_key.key}" }

  #     it 'returns nil' do
  #       expect(instance.api_key).to be_nil
  #     end
  #   end
  # end

  describe '#access_token' do
    subject(:instance) { described_class.new(authorization_str) }

    let(:access_token) { create(:access_token) }
    let(:api_key) { access_token.api_key }
    let(:authorization_str) do
      "Alexandria-Token access_token=#{access_token.user.id}:#{access_token.generate_token} \
      api_key=#{api_key.id}:#{api_key.key}"
    end

    context 'with valid authorization data' do
      it 'returns access token' do
        expect(instance.access_token).to eq access_token
      end
    end

    context 'with invalid authorization data' do
      context 'when api_key invalid' do
        let(:api_key) { build_stubbed(:api_key, id: 1, key: 'fake') }

        it 'returns nil' do
          expect(instance.access_token).to be_nil
        end
      end

      context 'when access token invalid' do
        let(:authorization_str) do
          "Alexandria-Token access_token=#{access_token.user.id}:#{access_token.generate_token && 'fake'} \
          api_key=#{api_key.id}:#{api_key.key}"
        end

        it 'returns nil' do
          expect(instance.access_token).to be_nil
        end
      end

      context 'when access token expired' do
        let(:access_token) { create(:access_token, created_at: 15.days.ago) }

        it 'returns nil and delete access token from db' do
          expect(access_token.expired?).to be true
          expect(instance.access_token).to be_nil
          expect(AccessToken.find_by(id: access_token.id)).to be_nil
        end
      end
    end
  end
end
