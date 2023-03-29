# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search' do
  let(:ruby_microscope) { create(:ruby_microscope) }
  let(:rails_tutorial) { create(:ruby_on_rails_tutorial) }
  let(:agile_web_dev) { create(:agile_web_development) }
  let(:books) { [ruby_microscope, rails_tutorial, agile_web_dev] }

  describe 'GET /api/search/:text' do
    before do
      books
      get "/api/search/#{text}"
    end

    context 'with text = ruby' do
      let(:text) { 'ruby' }

      it 'returns relevant entities' do
        expect(response).to have_http_status :ok
        json_body['data'].each do |document|
          expect(document['content']).to match(/ruby/i)
        end
      end
    end
  end
end
