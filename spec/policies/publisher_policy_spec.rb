# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublisherPolicy do
  # subject(:subject) { described_class }

  permissions :index?, :show? do
    it 'grants access' do
      expect(described_class).to permit(nil, Publisher.new)
    end
  end

  permissions :create?, :update?, :destroy? do
    it 'denies access if user is not admin' do
      expect(described_class).not_to permit(build(:user), Publisher.new)
    end

    it 'grants access if user is admin' do
      expect(described_class).to permit(build(:admin), Publisher.new)
    end
  end
end
