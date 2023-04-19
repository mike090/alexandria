# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'resource Publishers' do
  include ResourceHelpers

  let(:resource_name) { :publisher }
  let(:headers) { {} }

  describe 'GET /api/publishers' do
    let(:publishers) do
      [
        create(:publisher),
        create(:dev_media),
        create(:super_books)
      ]
    end

    include_context 'get resources'

    context 'without authentication' do
      it 'returns HTTP status 401' do
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with authentication' do
      include_context 'authenticate client'
      include_examples 'get resources examples'

      include_examples 'fields picking', pick_fields: %i[name id]
      include_examples 'pagination'
      include_examples 'sorting', sorting_column: :name
      include_examples 'filtering', filtering_column: :name, predicate: :cont, value: 'Book'
      include_examples 'embed picking', embed: :books
    end
  end

  describe 'GET /api/publishers/:id' do
    include_context 'get resource'

    context 'without authentication' do
      it 'returns HTTP status 401' do
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with authentication' do
      include_context 'authenticate client'
      include_examples 'get resource examples'
    end
  end

  describe 'POST /api/publishers' do
    include_context 'post resource'

    context 'without authentication' do
      it 'returns HTTP status 401' do
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with authentication' do
      include_context 'authenticate user', :admin
      include_examples 'post resource examples'
    end
  end

  describe 'PATCH /api/publishers/:id' do
    include_context 'patch resource'

    context 'without authentication' do
      it 'returns HTTP status 401' do
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with authentication' do
      include_context 'authenticate user', :admin
      include_examples 'patch resource examples'
    end
  end

  describe 'DELETE /api/publishers/:id' do
    include_context 'delete resource'

    context 'without authentication' do
      it 'returns HTTP status 401' do
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with authentication' do
      include_context 'authenticate user', :admin
      include_examples 'delete resource examples'
    end
  end
end
