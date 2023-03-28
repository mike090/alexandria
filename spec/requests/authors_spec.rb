# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authors' do
  let(:pat) { create(:author) }
  let(:michael) { create(:michael_hartl) }
  let(:sam) { create(:sam_ruby) }
  let(:authors) { [pat, michael, sam] }

  describe 'GET /api/authors' do
    let(:query) { query_params.any? ? "?#{query_params.map { |k, v| "#{k}=#{v}" }.join('&')}" : '' }

    before do
      authors
      get "/api/authors#{query}"
    end

    context 'with default behavior' do
      let(:query_params) { {} }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status :ok
      end

      it 'returns json with root key "data"' do
        expect(json_body['data']).not_to be_nil
      end

      it 'returns all authors' do
        expect(json_body['data'].count).to eq(Author.count)
      end
    end

    describe 'field picking' do
      let(:query_params) do
        requested_fields.any? ? { fields: requested_fields.join(',').to_s } : {}
      end

      context 'with the fields parameter' do
        let(:requested_fields) { %w[id family_name] }

        it 'returns only requested fields' do
          expect(response).to have_http_status :ok
          json_body['data'].each do |author|
            expect(author.keys).to eq requested_fields
          end
        end
      end

      context 'without the fields parameter' do
        let(:requested_fields) { [] }

        it 'returns all fields specified in AuthorPresenter' do
          expect(response).to have_http_status :ok
          json_body['data'].each do |author|
            expect(author.keys).to eq AuthorPresenter.build_attributes
          end
        end
      end

      context 'with invalid field name' do
        let(:requested_fields) { %w[first_name last_name] }

        it 'returns HTTP status 400' do
          expect(response).to have_http_status :bad_request
        end

        it 'returns an error data' do
          expect(json_body['error']).not_to be_nil
        end

        it 'returns an invalid parameters' do
          expect(json_body['error']['invalid_params']).to eq 'fields=first_name'
        end
      end
    end

    describe 'embed picking' do
      context 'with valid "embed" parameter' do
        let(:query_params) { { embed: :books } }

        it 'returns authors with their books embeded' do
          expect(response).to have_http_status :ok
          json_body['data'].each do |author|
            author['books'].each { |book| expect(book.keys).to eq(BookPresenter.build_attributes) }
          end
        end
      end

      context 'with invalid "embed" parameter' do
        let(:query_params) { { embed: :songs } }

        it 'returns HTTP status 400' do
          expect(response).to have_http_status :bad_request
        end

        it 'returns an error data' do
          expect(json_body['error']).not_to be_nil
        end

        it 'returns an invalid param' do
          expect(json_body['error']['invalid_params']).to eq 'embed=songs'
        end
      end
    end

    describe 'pagination' do
      context 'when asking for the first page' do
        let(:query_params) { { 'page' => 1, 'per' => 2 } }

        it 'returns HTTP status 200' do
          expect(response).to have_http_status :ok
        end

        it 'returns only two authors' do
          expect(json_body['data'].count).to eq 2
        end

        it 'returns a response with the Link header' do
          expect(response.headers['Link'].split(',').count).to eq 2
        end
      end

      context 'when asking for the second page' do
        let(:query_params) { { 'page' => 2, 'per' => 2 } }

        it 'returns HTTP status 200' do
          expect(response).to have_http_status :ok
        end

        it 'returns only one author' do
          expect(json_body['data'].count).to eq 1
        end
      end

      context 'when sending invalid "page" and "per" parameters' do
        let(:query_params) { { 'page' => 'fake', 'per' => 2 } }

        it 'returns HTTP status 400' do
          expect(response).to have_http_status :bad_request
        end

        it 'returns an error data' do
          expect(json_body['error']).not_to be_nil
        end

        it 'returns an invalid param' do
          expect(json_body['error']['invalid_params']).to eq 'page=fake'
        end
      end
    end

    describe 'sorting' do
      context 'when sorting column name is valid' do
        let(:query_params) { { sort: :given_name, dir: :desc } }

        it 'returns HTTP status 200' do
          expect(response).to have_http_status :ok
        end

        it 'returns sorting data' do
          expect(json_body['data'].map { |author| author['given_name'] }).to(
            eq(authors.map(&:given_name).sort.reverse)
          )
        end
      end

      context 'when sorting column name is invalid' do
        let(:query_params) { { sort: :first_name, dir: :asc } }

        it 'returns HTTP status 400' do
          expect(response).to have_http_status :bad_request
        end

        it 'returns an error data' do
          expect(json_body['error']).not_to be_nil
        end

        it 'returns an invalid param' do
          expect(json_body['error']['invalid_params']).to eq 'sort=first_name'
        end
      end

      context 'when sorting direction invalid' do
        let(:query_params) { { sort: :family_name, dir: :ascending } }

        it 'returns HTTP status 400' do
          expect(response).to have_http_status :bad_request
        end

        it 'returns an error data' do
          expect(json_body['error']).not_to be_nil
        end

        it 'returns an invalid param' do
          expect(json_body['error']['invalid_params']).to eq 'dir=ascending'
        end
      end
    end

    describe 'filtering' do
      context 'with valid filtering param "q[given_name_cont]=Pat"' do
        let(:query_params) { { 'q[given_name_eq]' => pat.given_name } }

        it 'returns HTTP status 200' do
          expect(response).to have_http_status :ok
        end

        it 'returns only one author - Pat Shaughnessy' do
          expect(json_body['data'].count).to eq 1
          expect(json_body['data'].first['id']).to eq pat.id
        end
      end

      context 'with invalid filtering param "q[fgiven_name_cont]=Pat"' do
        let(:query_params) { { 'q[fgiven_name_cont]' => 'Pat' } }

        it 'returns HTTP status 400' do
          expect(response).to have_http_status :bad_request
        end

        it 'returns an error data' do
          expect(json_body['error']).not_to be_nil
        end

        it 'returns an invalid param' do
          expect(json_body['error']['invalid_params']).to eq 'q[fgiven_name_cont]=Pat'
        end
      end
    end
  end

  describe 'GET /api/authors/:id' do
    before do
      authors
      get "/api/authors/#{id}"
    end

    context 'with existing resource' do
      let(:id) { pat.id }

      it 'returns the requested resource' do
        expect(response).to have_http_status :ok
        expect(response.body).to eq({ data: AuthorPresenter.new(pat, {}).fields }.to_json)
      end
    end

    context 'with nonexistent resource' do
      let(:id) { 12_345 }

      it 'returns HTTP status 404' do
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'POST /api/authors' do
    before { post '/api/authors', params: { data: author_params } }

    context 'with valid parameters' do
      let(:author_params) { attributes_for(:author) }

      it 'returns newly created resource' do
        expect(response).to have_http_status :created
        expect(response.body).to eq({ data: AuthorPresenter.new(Author.first, {}).fields }.to_json)
      end

      it 'adds a record to database' do
        expect(Author.count).to eq(1)
        expect(Author.first.attributes.symbolize_keys.slice(*author_params.keys)).to eq(author_params)
      end

      it 'returns the new resource location in the Location header' do
        expect(response.headers['Location']).to eq(
          "http://www.example.com/api/authors/#{Author.first.id}"
        )
      end
    end

    context 'with invalid parameters' do
      let(:author_params) { attributes_for(:author, family_name: '') }

      it 'returns HTTP status 422' do
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'returns the error details' do
        expect(json_body['error']['invalid_params']).to(
          eq({ 'family_name' => ["can't be blank"] })
        )
      end

      it 'does not add a record in the database' do
        expect(Author.count).to eq 0
      end
    end
  end

  describe 'PATCH /api/authors/:id' do
    let(:author) { create(:author, given_name: 'pat') }

    before { patch "/api/authors/#{author.id}", params: { data: author_params } }

    context 'with valid parameters' do
      let(:author_params) { { given_name: 'Pat' } }

      it 'updates record in the db and returns updated resource' do
        expect(response).to have_http_status :ok
        expect(Author.first.given_name).to eq 'Pat'
        expect(response.body).to eq({ data: AuthorPresenter.new(Author.first, {}).fields }.to_json)
      end
    end

    context 'with invalid parameters' do
      let(:author_params) { { given_name: '' } }

      it 'returns an error with details' do
        expect(response).to have_http_status :unprocessable_entity
        expect(json_body['error']['invalid_params']).to eq({ 'given_name' => ["can't be blank"] })
      end

      it 'does not updates the record in the db' do
        expect(Author.first.given_name).to eq 'pat'
      end
    end
  end

  describe 'DELETE /api/authors/:id' do
    let(:author) { create(:author) }

    before { delete "/api/authors/#{id}" }

    context 'with existing resource' do
      let(:id) { author.id }

      it 'deletes the record and returns HTTP status 204' do
        expect(response).to have_http_status :no_content
        expect(Author.count).to eq 0
      end
    end

    context 'with nonexistent resource' do
      let(:id) { 12_345 }

      it 'returns HTTP status 404' do
        expect(response).to have_http_status :not_found
      end
    end
  end
end
