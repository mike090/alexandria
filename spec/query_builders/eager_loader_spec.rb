# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EagerLoader do
  let(:scope) { Book.all }
  let(:params) { {} }
  let(:loader) { described_class.new(scope, params) }

  describe '#load' do
    context 'with valid parameters' do
      before { BookPresenter.related_to :author, :publisher }

      context 'with "include" parameter' do
        let(:params) { { 'include' => 'author,publisher' } }

        it 'returns scope with includes entityes' do
          expect(loader.load.includes_values).to eq %w[author publisher]
        end
      end

      context 'with "embed" parameter' do
        let(:params) { { 'embed' => 'publisher' } }

        it 'returns scope with includes entityes' do
          expect(loader.load.includes_values).to eq %w[publisher]
        end
      end
    end

    context 'with invalid parameters' do
      let(:params) { { 'include' => 'fake' } }

      it 'raises a QueryBuilderError exception' do
        expect { loader.load }.to raise_error QueryBuilderError
      end
    end
  end
end
