# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Publishers' do
  let(:oreilly) { create(:publisher) }
  let(:dev_media) { create(:dev_media) }
  let(:super_books) { create(:super_books) }
  let(:publishers) { [oreilly, dev_media, super_books] }

  describe 'GET /api/publishers' do
    let(:query) { query_params.any? ? "?#{query_params.map { |k, v| "#{k}=#{v}" }.join('&')}" : '' }

    before do
      publishers
      get "/api/publishers#{query}"
    end

    context 'with default behavior' do
      let(:query_params) { {} }

      it 'returns all publishers' do
        expect(response).to have_http_status :ok
        expect(json_body['data'].count).to eq(publishers.count)
        json_body['data'].each do |publisher|
          expect(publisher.keys).to eq(PublisherPresenter.build_attributes)
        end
      end
    end

    describe 'field picking' do
      let(:query_params) do
        requested_fields.any? ? { fields: requested_fields.join(',').to_s } : {}
      end

      context 'with the fields parameter' do
        let(:requested_fields) { %w[id name] }

        it 'returns only requested fields' do
          expect(response).to have_http_status :ok
          json_body['data'].each do |author|
            expect(author.keys).to eq requested_fields
          end
        end
      end

      context 'without the field parameter' do
        let(:requested_fields) { [] }

        it 'returns all fields specified in AuthorPresenter' do
          expect(response).to have_http_status :ok
          json_body['data'].each do |author|
            expect(author.keys).to eq PublisherPresenter.build_attributes
          end
        end
      end

      context 'with invalid field name "fid"' do
        let(:requested_fields) { %w[fid] }

        it 'returns error with invalid params' do
          expect(response).to have_http_status :bad_request
          expect(json_body['error']['invalid_params']).to eq 'fields=fid'
        end
      end
    end

    describe 'embed picking' do
      context 'with valid "embed" parameter' do
        let(:query_params) { { embed: :books } }

        it 'returns publishers with their books embeded' do
          expect(response).to have_http_status :ok
          json_body['data'].each do |publisher|
            publisher['books'].each { |book| expect(book.keys).to eq(BookPresenter.build_attributes) }
          end
        end
      end

      context 'with invalid "embed" parameter' do
        let(:query_params) { { embed: :songs } }

        it 'returns error with invalid params' do
          expect(response).to have_http_status :bad_request
          expect(json_body['error']).not_to be_nil
          expect(json_body['error']['invalid_params']).to eq 'embed=songs'
        end
      end
    end

    describe 'pagination' do
      context 'when asking for the first page' do
        let(:query_params) { { per: 2 } }

        it 'returns only two publishers' do
          expect(response).to have_http_status :ok
          expect(json_body['data'].count).to eq 2
        end
      end

      context 'when asking for the second page' do
        let(:query_params) { { page: 2, per: 2 } }

        it 'returns only one publisher' do
          expect(response).to have_http_status :ok
          expect(json_body['data'].count).to eq 1
        end
      end

      context 'when sending invalid "page" and "per" parameters' do
        let(:query_params) { { page: :last, per: :four } }

        it 'returns an error with invalid params' do
          expect(response).to have_http_status :bad_request
          expect(json_body['error']['invalid_params']).to eq('page=last')
        end
      end
    end

    describe 'sorting' do
      context 'with valid column name "id"' do
        let(:query_params) { { sort: :id } }

        it 'returns sorting data' do
          expect(response).to have_http_status :ok
          expect(json_body['data'].map { |publisher| publisher['id'] }).to eq([1, 2, 3])
        end
      end

      context 'with invalid column name "fid"' do
        let(:query_params) { { sort: :fid } }

        it 'returns an error with invalid params' do
          expect(response).to have_http_status :bad_request
          expect(json_body['error']['invalid_params']).to eq('sort=fid')
        end
      end
    end

    describe 'filtering' do
      context 'with valid filtering param "q[name_cont]=Reilly"' do
        let(:query_params) { { 'q[name_cont]' => 'Reilly' } }

        it 'returns filtred data' do
          expect(response).to have_http_status :ok
          expect(json_body['data'].count).to eq 1
          expect(json_body['data'].first['name']).to match(/Reilly/)
        end
      end

      context 'with invalid filtering param "q[fname_cont]=Reilly"' do
        let(:query_params) { { 'q[fname_cont]' => 'Reilly' } }

        it 'returns an error with invalid params' do
          expect(response).to have_http_status :bad_request
          expect(json_body['error']['invalid_params']).to eq('q[fname_cont]=Reilly')
        end
      end
    end
  end

  describe 'GET /api/publishers/:id' do
    before do
      publishers
      get "/api/publishers/#{id}"
    end

    context 'with existing resource' do
      let(:id) { oreilly.id }

      it 'returns the requested resource' do
        expect(response).to have_http_status :ok
        expect(response.body).to eq({ data: PublisherPresenter.new(Publisher.find(id), {}).fields }.to_json)
      end
    end

    context 'with nonexistent resource' do
      let(:id) { 12_345 }

      it 'responds with 404' do
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'POST /api/publishers' do
    before { post '/api/publishers', params: { data: publisher_params } }

    context 'with valid parameters' do
      let(:publisher_params) { attributes_for(:publisher) }

      it 'responds with 201 and returns newly created resource' do
        expect(response).to have_http_status :created
        expect(response.body).to eq({ data: PublisherPresenter.new(Publisher.first, {}).fields }.to_json)
      end

      it 'adds a record to database' do
        expect(Publisher.count).to eq(1)
        expect(Publisher.first.attributes.symbolize_keys.slice(*publisher_params.keys)).to eq(publisher_params)
      end

      it 'returns the new resource location in the Location header' do
        expect(response.headers['Location']).to eq(
          "http://www.example.com/api/publishers/#{Publisher.first.id}"
        )
      end
    end

    context 'with invalid parameters' do
      let(:publisher_params) { attributes_for(:publisher, name: '') }

      it 'responds with 422 and returns error with invalid params' do
        expect(response).to have_http_status :unprocessable_entity
        expect(json_body['error']['invalid_params']).to(
          eq({ 'name' => ["can't be blank"] })
        )
      end

      it 'does not add a record to database' do
        expect(Publisher.count).to eq 0
      end
    end
  end

  describe 'PATCH /api/publishers/:id' do
    let(:publisher) { create(:publisher, name: "O'Reily") }

    before { patch "/api/publishers/#{publisher.id}", params: { data: publisher_params } }

    context 'with valid parameters' do
      let(:publisher_params) { { name: "O'Reilly" } }

      it 'updates db record and returns updated resource representation' do
        expect(response).to have_http_status :ok
        expect(Publisher.first.name).to eq "O'Reilly"
        expect(response.body).to eq({ data: PublisherPresenter.new(Publisher.first, {}).fields }.to_json)
      end
    end

    context 'with invalid parameters' do
      let(:publisher_params) { { name: '' } }

      it 'responds with 422 and returns error with invalid params' do
        expect(response).to have_http_status :unprocessable_entity
        expect(json_body['error']['invalid_params']).to eq({ 'name' => ["can't be blank"] })
      end

      it 'does not updates db record' do
        expect(Publisher.first.name).to eq("O'Reily")
      end
    end
  end

  describe 'DELETE /api/publishers/:id' do
    let(:publisher) { create(:publisher) }

    before { delete "/api/publishers/#{id}" }

    context 'with existing resource' do
      let(:id) { publisher.id }

      it 'deletes the record and returns HTTP status 204' do
        expect(response).to have_http_status :no_content
        expect(Publisher.count).to eq 0
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
