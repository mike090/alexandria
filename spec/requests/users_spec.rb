# frozen_string_literal: true

require 'rails_helper'
require 'action_mailer'

RSpec.describe 'resource Users' do
  include ResourceHelpers

  let(:resource_name) { :user }
  let(:headers) { {} }

  describe 'GET /api/users' do
    let(:users) { [create(:user)] }

    include_context 'get resources'

    context 'without authentication' do
      it 'returns HTTP status 401' do
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with authentication' do
      include_context 'authenticate user', :admin
      include_examples 'get resources examples'

      include_examples 'fields picking', pick_fields: %i[given_name family_name]
      # include_examples 'pagination'
      include_examples 'sorting', sorting_column: :given_name
      include_examples 'filtering', filtering_column: :given_name, predicate: :cont, value: 'john'
      # include_examples 'embed picking', embed: :books
    end
  end

  describe 'GET /api/users/:id' do
    include_context 'get resource'

    context 'without authentication' do
      it 'returns HTTP status 401' do
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with authentication' do
      include_context 'authenticate user', :admin
      include_examples 'get resource examples'
    end
  end

  describe 'POST /api/users' do
    include_context 'post resource'

    context 'without authentication' do
      it 'returns HTTP status 401' do
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with authentication' do
      include_context 'authenticate client'

      context 'with valid parameters' do
        it 'adds a record to db, returns created user with location' do
          expect(response).to have_http_status :created
          created = model.find_by(**resource_data.except(:password))
          expect(response.body).to eq({ data: resource_presenter.new(created, {}).fields }.to_json)
          expect(created).not_to be_nil
          expected = resource_data.except(:password).transform_values(&:to_s)
          expect(created.attributes.symbolize_keys).to include expected
          expect(response.headers['Location']).to eq(
            "http://www.example.com/api/#{pluralized_name}/#{created.id}"
          )
        end

        it 'sends email confirmation', :skip_request do
          expect { post('/api/users', params:, headers:) }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with('UserMailer', 'confirmation_email', 'deliver_now', Hash)
        end
      end

      context 'with invalid parameters' do
        let(:resource_data) { invalid_resource }

        it 'does not add a record to db, returns HTTP status 422 with error details' do
          expect(response).to have_http_status :unprocessable_entity
          expect(model.find_by(**resource_data.except(:password))).to be_nil
          expect(json_body['error']['invalid_params'].symbolize_keys).to(
            include(*invalid_attributes.keys)
          )
        end
      end
    end
  end

  describe 'PATCH /api/users/:id' do
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

  describe 'DELETE /api/users/:id' do
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
