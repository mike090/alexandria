# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  let(:user) { build(:user) }

  it 'has a valid factory' do
    expect(build(:user)).to be_valid
  end

  it { is_expected.to validate_presence_of :email }
  it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
  it { is_expected.to validate_presence_of :password }

  it 'generates a confirmation token' do
    user.valid?
    expect(user.confirmation_token).not_to be_nil
  end

  it 'downcases email before validation' do
    user.email = 'Jhon@example.com'
    expect(user).to be_valid
    expect(user.email).to eq 'jhon@example.com'
  end
end
