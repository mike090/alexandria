# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filter do
  let(:ruby_microscope) { create(:ruby_microscope) }
  let(:rails_tutorial) { create(:ruby_on_rails_tutorial) }
  let(:agile_web_dev) { create(:agile_web_development) }
  let(:books) { [ruby_microscope, rails_tutorial, agile_web_dev] }

  let(:scope) { Book.all }
  let(:params) { {} }
  let(:filter) { described_class.new(scope, params) }
  let(:filtred) { filter.filter }

  before do
    allow(BookPresenter).to receive(:filter_attributes).and_return(%w[id title released_on])
    books
  end

  describe '#filter' do
    context 'without any parameters' do
      it 'returns the unchanged scope' do
        expect(filtred).to eq scope
      end
    end

    context 'with walid parameters' do
      context 'with {filed}_eq parameter' do
        let(:params) { { 'q' => { 'title_eq' => 'Ruby Under a Microscope' } } }

        it 'returns filtred scope' do
          expect(filtred.count).to eq 1
          expect(filtred.first.id).to eq ruby_microscope.id
        end
      end

      context 'with {filed}_cont parameter' do
        let(:params) { { 'q' => { 'title_cont' => 'Under' } } }

        it 'returns filtred scope' do
          expect(filtred.count).to eq 1
          expect(filtred.first.id).to eq ruby_microscope.id
        end
      end

      context 'with {field}_notcont parameter' do
        let(:params) { { 'q' => { 'title_notcont' => 'Ruby' } } }

        it 'returns filtred scope' do
          expect(filtred.count).to eq 1
          expect(filtred.first.id).to eq agile_web_dev.id
        end
      end

      context 'with {filed}_start parameter' do
        let(:params) { { 'q' => { 'title_start' => 'Ruby' } } }

        it 'returns filtred scope' do
          expect(filtred.count).to eq 2
          expect(filtred).not_to include agile_web_dev
        end
      end

      context 'with {filed}_end parameter' do
        let(:params) { { 'q' => { 'title_end' => 'Tutorial' } } }

        it 'returns filtred scope' do
          expect(filtred.count).to eq 1
          expect(filtred.first.id).to eq rails_tutorial.id
        end
      end

      context 'with {filed}_lt parameter' do
        let(:params) { { 'q' => { 'released_on_lt' => '2013-05-10' } } }

        it 'returns filtred scope' do
          expect(filtred.count).to eq 1
          expect(filtred.first.id).to eq rails_tutorial.id
        end
      end

      context 'with {filed}_gt parameter' do
        let(:params) { { 'q' => { 'released_on_gt' => '2014-01-01' } } }

        it 'returns filtred scope' do
          expect(filtred.count).to eq 1
          expect(filtred.first.id).to eq agile_web_dev.id
        end
      end
    end

    context 'with invalid parameters' do
      context 'when invalid column name' do
        let(:params) { { 'q' => { 'fid_eq' => '5' } } }

        it 'raises a QueryBuilderError exception' do
          expect { filtred }.to raise_error QueryBuilderError
        end
      end

      context 'when invalid predicate' do
        let(:params) { { 'q' => { 'id_noteq' => '1' } } }

        it 'raises a QueryBuilderError exception' do
          expect { filtred }.to raise_error QueryBuilderError
        end
      end
    end
  end
end
