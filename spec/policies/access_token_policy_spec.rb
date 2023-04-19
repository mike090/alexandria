# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessTokenPolicy do
  permissions :create? do
    it 'grants access for all' do
      expect(described_class).to permit(nil, AccessToken.new)
    end
  end

  permissions :destroy? do
    it 'denies access for admin' do
      expect(described_class).not_to permit(build(:admin), AccessToken.new)
    end

    it 'grants access to its access token' do
      access_token = build(:access_token)
      expect(described_class).to permit(access_token.user, access_token)
    end
  end
end
