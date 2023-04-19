# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy do
  # subject(:subject) { described_class }

  permissions :index?, :show? do
    it 'denies access for guests' do
      expect(described_class).not_to permit(nil, User.new)
    end

    it 'denies access if user is not admin' do
      expect(described_class).not_to permit(build(:user), User.new)
    end

    it 'grants access for admin' do
      expect(described_class).to permit(build(:admin), User.new)
    end
  end

  permissions :create? do
    it 'grants access for all' do
      expect(described_class).to permit(nil, User.new)
    end
  end

  permissions :update?, :destroy? do
    it 'denies access for not admin' do
      expect(described_class).not_to permit(build(:user), User.new)
    end

    it 'grants access to owned record' do
      user = build(:user)
      expect(described_class).to permit(user, user)
    end

    it 'grants access if user is admin' do
      expect(described_class).to permit(build(:admin), User.new)
    end
  end
end
