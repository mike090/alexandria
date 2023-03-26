# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Books' do
  let(:ruby_microscope) { create(:ruby_microscope) }
  let(:rails_tutorial) { create(:ruby_on_rails_tutorial) }
  let(:agile_web_dev) { create(:agile_web_development) }

  let(:books) { [ruby_microscope, rails_tutorial, agile_web_dev] }

  describe 'GET /api/books' do
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
end
