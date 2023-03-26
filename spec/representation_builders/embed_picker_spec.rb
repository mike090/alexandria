# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmbedPicker do
  let(:author) { create(:michael_hartl) }
  let(:ruby_microscope) { create(:ruby_microscope, author_id: author.id) }
  let(:rails_tutorial) { create(:ruby_on_rails_tutorial, author_id: author.id) }

  let(:params) { {} }
  let(:embed_picker) { described_class.new(presenter) }

  describe '#embed' do
    context 'with books as the resource (many-to-one)' do
      let(:presenter) { BookPresenter.new rails_tutorial, params }

      before { allow(BookPresenter).to receive(:relations).and_return(['author']) }

      context 'without "embed" parameter' do
        it 'returns the "data" hash without changing it' do
          expect(embed_picker.embed.data).to eq presenter.data
        end
      end

      context 'with valid "embed" parameter ("author")' do
        let(:params) { { embed: 'author' } }

        it 'embeds the "author" data' do
          expect(embed_picker.embed.data[:author]).to eq(
            { 'id' => rails_tutorial.author.id, 'given_name' => author.given_name, 'family_name' => author.family_name,
              'created_at' => author.created_at, 'updated_at' => author.updated_at }
          )
        end
      end

      context 'with invalid "embed" parameter ("language")' do
        let(:params) { { embed: 'something' } }

        it 'raises a "RepresentationBuilderError"' do
          expect { embed_picker.embed }.to raise_error RepresentationBuilderError
        end
      end
    end

    context 'with author as resource (one-to-many)' do
      let(:params) { { embed: 'books' } }
      let(:presenter) { AuthorPresenter.new(author, params) }

      before do
        ruby_microscope && rails_tutorial
        allow(AuthorPresenter).to receive(:relations).and_return(['books'])
      end

      it 'embeds the "books" data' do
        expect(embed_picker.embed.data[:books].count).to eq 2
        expect(embed_picker.embed.data[:books].first['id']).to eq ruby_microscope.id
        expect(embed_picker.embed.data[:books].last['id']).to eq rails_tutorial.id
      end
    end
  end
end
