# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessToken do
  let(:access_token) { create(:access_token) }

  it 'has a valid factory' do
    expect(build(:access_token)).to be_valid
  end

  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:api_key) }

  describe '#authenticate' do
    context 'when valid' do
      it 'authenticates' do
        token = access_token.generate_token
        expect(access_token.authenticate(token)).to be_truthy
      end
    end

    context 'when invalid' do
      it 'fails to authenticate' do
        access_token.generate_token
        expect(access_token.authenticate('fake')).to be_falsey
      end
    end
  end

  describe '#expired?' do
    context 'when expired' do
      it 'returns true' do
        access_token.update_column(:created_at, 15.days.ago)
        expect(access_token).to be_expired
      end
    end

    context 'when not expired' do
      it 'returns false' do
        access_token.update_column(:created_at, 10.days.ago)
        expect(access_token).not_to be_expired
      end
    end
  end

  describe '#generate_token' do
    it 'generates an access token digest and returns an access token' do
      token = access_token.generate_token
      expect(access_token.token_digest).not_to be_nil
      expect(token).not_to be_nil
    end
  end
end
