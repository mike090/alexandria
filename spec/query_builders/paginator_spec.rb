# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Paginator do
  let(:ruby_microscope) { create(:ruby_microscope) }
  let(:rails_tutorial) { create(:ruby_on_rails_tutorial) }
  let(:agile_web_dev) { create(:agile_web_development) }
  let(:books) { [ruby_microscope, rails_tutorial, agile_web_dev] }

  let(:scope) { Book.all }
  let(:page) { 1 }
  let(:per) { 2 }
  let(:params) { { 'page' => page.to_s, 'per' => per.to_s } }
  let(:paginator) { described_class.new(scope, params, 'url') }

  before { books }

  describe '#paginate' do
    let(:paginated) { paginator.paginate }

    it 'paginates the collection with 2 books' do
      expect(paginated.count).to eq 2
    end

    it 'contains ruby_microscope as the first paginated item' do
      expect(paginated.first).to eq ruby_microscope
    end

    it 'contains rails_tutorial as the last paginated item' do
      expect(paginated.last).to eq rails_tutorial
    end
  end

  describe '#links' do
    let(:per) { 1 }
    let(:first_page_link) { "<url?page=1&per=#{per}>; rel=\"first\"" }
    let(:last_page_link) { "<url?page=3&per=#{per}>; rel=\"last\"" }
    let(:prev_page_link) { "<url?page=#{page - 1}&per=1>; rel=\"prev\"" }
    let(:next_page_link) { "<url?page=#{page + 1}&per=1>; rel=\"next\"" }
    let(:links) { paginator.links }

    context 'when page is in total pages range' do
      context 'when first page' do
        let(:page) { 1 }

        it 'returns only "next" and "last" links' do
          expect(links).to eq([
            next_page_link,
            last_page_link
          ].join(', '))
        end
      end

      context 'when "middle" page' do
        let(:page) { 2 }

        it 'returns all four links' do
          expect(links).to eq([first_page_link, prev_page_link, next_page_link, last_page_link].join(', '))
        end
      end

      context 'when last page' do
        let(:page) { 3 }

        it 'returns only "first" and "prev" links' do
          expect(links).to eq([
            first_page_link,
            prev_page_link
          ].join(', '))
        end
      end
    end

    context 'when page is out of range' do
      let(:page) { 7 }

      it 'returns only "first" and "last" links' do
        expect(links).to eq([
          first_page_link,
          last_page_link
        ].join(', '))
      end
    end
  end
end
