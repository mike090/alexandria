# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'resource Books' do
  include ResourceHelpers

  let(:resource_name) { :book }
  let(:headers) { {} }

  describe 'GET /api/books' do
    let(:books) do
      [
        create(:ruby_microscope),
        create(:ruby_on_rails_tutorial),
        create(:agile_web_development)
      ]
    end

    include_context 'get resources'

    context 'without authentication' do
      it 'returns HTTP status 401' do
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with authentication' do
      include_context 'authentication'
      include_examples 'get resources examples'

      include_examples 'fields picking', pick_fields: %i[title isbn_13]
      include_examples 'pagination'
      include_examples 'sorting', sorting_column: :title
      include_examples 'filtering', filtering_column: :title, predicate: :cont, value: 'Ruby'
      include_examples 'embed picking', embed: :author
    end
  end

  describe 'GET /api/books/:id' do
    include_context 'get resource'

    context 'without authentication' do
      it 'returns HTTP status 401' do
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with authentication' do
      include_context 'authentication'
      include_examples 'get resource examples'
    end
  end

  describe 'POST /api/books' do
    include_context 'post resource'

    context 'without authentication' do
      it 'returns HTTP status 401' do
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with authentication' do
      include_context 'authentication'
      include_examples 'post resource examples'
    end
  end

  describe 'PATCH /api/books/:id' do
    include_context 'patch resource'

    context 'without authentication' do
      it 'returns HTTP status 401' do
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with authentication' do
      include_context 'authentication'
      include_examples 'patch resource examples'
    end
  end

  describe 'DELETE /api/books/:id' do
    include_context 'delete resource'

    context 'without authentication' do
      it 'returns HTTP status 401' do
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with authentication' do
      include_context 'authentication'
      include_examples 'delete resource examples'
    end
  end
end
