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
  end
end
