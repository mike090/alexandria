# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'resource Authors' do
  include ResourceHelpers

  let(:resource_name) { :author }
  let(:headers) { {} }

  describe 'GET /api/authors' do
    let(:authors) do
      [
        create(:author),
        create(:michael_hartl),
        create(:sam_ruby)
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

      include_examples 'fields picking', pick_fields: %i[given_name created_at]
      include_examples 'pagination'
      include_examples 'sorting', sorting_column: :family_name
      include_examples 'filtering', filtering_column: :given_name, predicate: :notcont, value: 'Sam'
      include_examples 'embed picking', embed: :books
    end
  end

  describe 'GET /api/authors/:id' do
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

  describe 'POST /api/authors' do
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

  describe 'PATCH /api/authors/:id' do
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

  describe 'DELETE /api/authors/:id' do
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
