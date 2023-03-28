# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Books' do
  describe 'GET /api/books' do
    let(:ruby_microscope) { create(:ruby_microscope) }
    let(:rails_tutorial) { create(:ruby_on_rails_tutorial) }
    let(:agile_web_dev) { create(:agile_web_development) }

    let(:books) { [ruby_microscope, rails_tutorial, agile_web_dev] }

    before { books }

    context 'when behavior is default' do
      before { get '/api/books' }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status :ok
      end

      it 'returns a json with the "data" root key' do
        expect(json_body['data']).not_to be_nil
      end

      it 'returns all 3 books' do
        expect(json_body['data'].length).to eq(3)
      end
    end

    describe 'field picking' do
      context 'with the "field" parameter' do
        before { get '/api/books?fields=id,title,author_id' }

        it 'returns books with only the id, title and author_id keys' do
          json_body['data'].each do |book|
            expect(book.keys).to eq %w[id title author_id]
          end
        end
      end

      context 'without the "fields" parameter' do
        before { get '/api/books' }

        it 'returns books with all the fields specified in the presenter' do
          json_body['data'].each do |book|
            expect(book.keys).to eq BookPresenter.build_attributes.map(&:to_s)
          end
        end
      end

      context 'with invalid "fields" parameter' do
        before { get '/api/books?fields=fid,title,author_id' }

        it 'returns 400 "Bad Request"' do
          expect(response).to have_http_status :bad_request
        end

        it 'returns an error' do
          expect(json_body['error']).not_to be_nil
        end

        it 'returns an invalid params' do
          expect(json_body['error']['invalid_params']).to eq 'fields=fid'
        end
      end
    end

    describe 'embed picking' do
      context 'with the "embed" parameter' do
        before { get '/api/books?embed=author' }

        it 'returns the books with their authors embedded' do
          json_body['data'].each do |book|
            expect(book['author'].keys).to eq AuthorPresenter.build_attributes
          end
        end
      end

      context 'with invalid "embed" parameter' do
        before { get '/api/books?embed=fake' }

        it 'returns 400 "Bad Request"' do
          expect(response).to have_http_status :bad_request
        end

        it 'returns an error' do
          expect(json_body['error']).not_to be_nil
        end

        it 'returns invalid parameter' do
          expect(json_body['error']['invalid_params']).to eq 'embed=fake'
        end
      end
    end

    describe 'pagination' do
      context 'when asking for the first page' do
        before { get '/api/books?per=2' }

        it 'returns HTTP status 200' do
          expect(response).to have_http_status :ok
        end

        it 'returns only two books' do
          expect(json_body['data'].count).to eq 2
        end

        it 'returns a response with the Link header' do
          expect(response.headers['Link'].split(', ').count).to eq 2
        end
      end

      context 'when asking for the second page' do
        before { get '/api/books?per=2&page=2' }

        it 'returns HTTP status 200' do
          expect(response).to have_http_status :ok
        end

        it 'returns only one book' do
          expect(json_body['data'].count).to eq 1
        end
      end

      context "when sending invalid 'page' and 'per' parameters" do
        before { get('/api/books?page=fake&per=10') }

        it 'returns HTTP status 400' do
          expect(response).to have_http_status :bad_request
        end

        it 'returns error data' do
          expect(json_body['error']).not_to be_nil
        end

        it 'returns an invalid param' do
          expect(json_body['error']['invalid_params']).to eq 'page=fake'
        end
      end
    end

    describe 'sorting' do
      context 'when sorting column name is valid' do
        it 'sorts the books by "id desc"' do
          get '/api/books?sort=id&dir=desc'
          expect(json_body['data'].first['id']).to eq agile_web_dev.id
          expect(json_body['data'].last['id']).to eq ruby_microscope.id
        end
      end

      context 'when sorting column name is invalid' do
        before { get '/api/books?sort=fid&dir=asc' }

        it 'returns HTTP status 400' do
          expect(response).to have_http_status :bad_request
        end

        it 'returns error data' do
          expect(json_body['error']).not_to be_nil
        end

        it 'returns an invalid param' do
          expect(json_body['error']['invalid_params']).to eq 'sort=fid'
        end
      end
    end

    describe 'filtering' do
      context 'with valid filtering parameters' do
        it 'returns items matching the filter' do
          get '/api/books?q[title_cont]=Microscope'
          expect(response).to have_http_status :ok
          expect(json_body['data'].first['id']).to eq ruby_microscope.id
          expect(json_body['data'].count).to eq 1
        end
      end

      context 'with invalid filtering parameters' do
        before { get '/api/books?q[ftitle_cont]=Ruby' }

        it 'returns Bad Request status response' do
          expect(response).to have_http_status :bad_request
        end

        it 'retuns an error data' do
          expect(json_body['error']).not_to be_nil
        end

        it 'returns an invalid param data' do
          expect(json_body['error']['invalid_params']).to eq 'q[ftitle_cont]=Ruby'
        end
      end
    end
  end

  describe 'GET /api/books/:id' do
    let(:rails_tutorial) { create(:ruby_on_rails_tutorial) }

    context 'with existing resource' do
      before { get "/api/books/#{rails_tutorial.id}" }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status :ok
      end

      it 'returns the "rails_tutorial" book as JSON' do
        expected = { data: BookPresenter.new(rails_tutorial, {}).fields.embeds }.to_json
        expect(response.body).to eq expected
      end
    end

    context 'with nonexisting resource' do
      it 'returns HTTP status 404' do
        get '/api/books/12345'
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'POST /api/books' do
    let(:author) { create(:michael_hartl) }

    before { post '/api/books', params: { data: params } }

    context 'with valid parameters' do
      let(:params) { attributes_for(:ruby_on_rails_tutorial, author_id: author.id) }

      it 'returns HTTP status 201' do
        expect(response).to have_http_status :created
      end

      it 'returns the newly created resource' do
        expect(json_body['data']['title']).to eq 'Ruby on Rails Tutorial'
      end

      it 'adds a record to database' do
        expect(Book.count).to eq 1
      end

      it 'returns the new resource location in the Location header' do
        expect(response.headers['Location']).to eq(
          "http://www.example.com/api/books/#{Book.first.id}"
        )
      end
    end

    context 'with invalid parameters' do
      let(:params) { attributes_for(:ruby_on_rails_tutorial, title: '') }

      it 'returns HTTP status 422' do
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'returns the error details' do
        expect(json_body['error']['invalid_params']).to(
          eq({ 'author' => ["can't be blank", 'must exist'], 'title' => ["can't be blank"] })
        )
      end

      it 'does not add a record in the database' do
        expect(Book.count).to eq 0
      end
    end
  end

  describe 'PATCH /api/books/:id' do
    let(:book) { create(:ruby_on_rails_tutorial) }

    before { patch "/api/books/#{book.id}", params: { data: params } }

    context 'with valid parameters' do
      let(:params) { { title: 'The Ruby on Rails Tutorial' } }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status :ok
      end

      it 'returns the updated resource' do
        expect(json_body['data']['title']).to eq 'The Ruby on Rails Tutorial'
      end

      it 'updates record in the database' do
        expect(Book.first.title).to eq 'The Ruby on Rails Tutorial'
      end
    end

    context 'with invalid parameters' do
      let(:params) { { title: '' } }

      it 'returns HTTP status 422' do
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'returns the error details' do
        expect(json_body['error']['invalid_params']).to eq(
          { 'title' => ["can't be blank"] }
        )
      end

      it 'does not updated the record in the database' do
        expect(Book.first.title).to eq 'Ruby on Rails Tutorial'
      end
    end
  end

  describe 'DELETE /api/books/:id' do
    let(:book) { create(:ruby_on_rails_tutorial) }

    context 'with existing resource' do
      before { delete "/api/books/#{book.id}" }

      it 'returns HTTP status 204' do
        expect(response).to have_http_status :no_content
      end

      it 'deletes the book from the database' do
        expect(Book.count).to eq 0
      end
    end

    context 'with nonexisting resource' do
      it 'returns HTTP status 404' do
        delete '/api/books/12345'
        expect(response).to have_http_status :not_found
      end
    end
  end
end
