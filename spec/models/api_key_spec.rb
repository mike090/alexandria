# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiKey do
  let(:key) { described_class.create }

  it 'is valid on creation' do
    expect(key).to be_valid
  end

  describe 'validation' do
    it { is_expected.to validate_presence_of(:active) }
  end

  describe '"key" attribute' do
    it 'inits on object creation' do
      expect(described_class.new.key).not_to be_nil
    end

    it 'ignores initial values' do
      expect(described_class.new(key: 'value').key).not_to eq('value')
    end

    it 'ignores changing' do
      key.key = 'value'
      expect(key.key).not_to eq('value')
    end

    it 'is hexadecimail number' do
      expect(key.key).to match(/^[0-9a-f]+/)
    end
  end

  describe '#disable' do
    it 'disables the key' do
      key.disable
      expect(key.reload.active).to be false
    end
  end
end
