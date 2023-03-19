# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Publisher do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to have_many(:books) }

  it 'has a valid factory' do
    expect(build(:publisher)).to be_valid
  end
end
