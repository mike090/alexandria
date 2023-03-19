# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Book do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:released_on) }
  it { is_expected.to validate_presence_of(:author) }
  it { is_expected.to validate_presence_of(:isbn_10) }
  it { is_expected.to validate_presence_of(:isbn_13) }

  it { is_expected.to validate_length_of(:isbn_10).is_equal_to(10) }
  it { is_expected.to validate_length_of(:isbn_13).is_equal_to(13) }

  it { is_expected.to validate_uniqueness_of(:isbn_10) }
  it { is_expected.to validate_uniqueness_of(:isbn_13) }

  it { is_expected.to belong_to(:author) }
  it { is_expected.to belong_to(:publisher).optional }

  it 'has a valid factory' do
    expect(build(:book)).to be_valid
  end
end
