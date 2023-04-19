# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookPolicy do
  # subject(:subject) { described_class }

  permissions :index?, :show? do
    it 'grants access' do
      expect(described_class).to permit(nil, Book.new)
    end
  end

  permissions :create?, :update?, :destroy? do
    it 'denies access if user is not admin' do
      expect(described_class).not_to permit(build(:user), Book.new)
    end

    it 'grants access if user is admin' do
      expect(described_class).to permit(build(:admin), Book.new)
    end
  end
end
