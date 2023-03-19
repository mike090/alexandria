# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Author do
  it { is_expected.to validate_presence_of(:given_name) }
  it { is_expected.to validate_presence_of(:family_name) }
  it { is_expected.to have_many(:books) }

  it 'has a valid factory' do
    expect(build(:author)).to be_valid
  end
end
