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
  end
end
