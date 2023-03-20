# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FieldPicker do
  let(:rails_tutorial) { create(:ruby_on_rails_tutorial) }
  let(:params) { { fields: 'id,title,sublitle' } }
  let(:presenter) { BookPresenter.new(rails_tutorial, params) }
  let(:field_picker) { described_class.new(presenter) }

  before do
    allow(BookPresenter).to(
      receive(:build_attributes).and_return(%w[id title author_id])
    )
  end

  describe '#pick' do
    context 'with the "fields" parameter containing "id,title,subtitle"' do
      it 'updates the presenter "data" with the book "id" and "title"' do
        expect(field_picker.pick.data).to eq({
                                               'id' => rails_tutorial.id,
                                               'title' => rails_tutorial.title
                                             })
      end

      context 'with overriding method defined in presenter' do
        before { presenter.class.send(:define_method, :title) { 'Overridden!' } }
        after { presenter.class.send(:remove_method, :title) }

        it 'updates the presenter "data" with the title "Overridden!"' do
          expect(field_picker.pick.data).to eq({
                                                 'id' => rails_tutorial.id,
                                                 'title' => 'Overridden!'
                                               })
        end
      end
    end

    context 'with no "fields" parameter' do
      let(:params) { {} }

      it 'updates "data" with the fields ("id","title","author_id")' do
        expect(field_picker.send(:pick).data).to eq({
                                                      'id' => rails_tutorial.id,
                                                      'title' => rails_tutorial.title,
                                                      'author_id' => rails_tutorial.author.id
                                                    })
      end
    end
  end
end
