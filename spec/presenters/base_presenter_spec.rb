# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BasePresenter do
  # class Presenter < BasePresenter; end
  let(:presenter) { described_class.new('fake', { something: 'cool' }) }

  describe '#initialize' do
    it 'sets the "object" variable with "fake"' do
      expect(presenter.object).to eq 'fake'
    end

    it 'sets the "params" variable with { something: "cool" }' do
      expect(presenter.params).to eq({ something: 'cool' })
    end

    it 'does something' do
      expect(presenter.data).to be_a(HashWithIndifferentAccess)
    end
  end

  describe '#as_json' do
    it 'allows the serialialization of "data" to json' do
      presenter.data = { something: 'cool' }
      expect(presenter.to_json).to eq '{"something":"cool"}'
    end
  end

  describe '.build_with' do
    it 'stores ["id", "title"] in "build_attributes"' do
      described_class.build_with :id, :title
      expect(described_class.build_attributes).to eq %w[id title]
    end
  end

  describe '.related_to' do
    it 'stores the correct value' do
      described_class.related_to :author, :publisher
      expect(described_class.relations).to eq %w[author publisher]
    end
  end

  describe '.sort_by' do
    it 'stores the correct value' do
      described_class.sort_by :id, :title
      expect(described_class.sort_attributes).to eq %w[id title]
    end
  end

  describe '.filter_by' do
    it 'stores the correct value' do
      described_class.filter_by :title
      expect(described_class.filter_attributes).to eq %w[title]
    end
  end
end
