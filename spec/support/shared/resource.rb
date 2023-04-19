# frozen_string_literal: true

shared_context 'post resource' do
  let(:params) { { data: resource_data } }
  let(:resource_data) { attributes_for(resource_name).merge(belongs_keys) }
  let(:belongs_keys) do
    reflections = model.reflect_on_all_associations(:belongs_to).reject do |reflection|
      reflection.options[:optional]
    end
    reflections.to_h { |reflection| ["#{reflection.name}_id".to_sym, create(reflection.name).id] }
  end

  before { |test| post("/api/#{pluralized_name}", params:, headers:) unless test.metadata[:skip_request] }
end

shared_examples 'post resource examples' do
  context 'with valid parameters' do
    it 'adds a record to db and returns created resource with location' do
      expect(response).to have_http_status :created
      expect(response.body).to eq({ data: resource_presenter.new(model.first, {}).fields }.to_json)
      created = model.find_by(**resource_data)
      expect(created).not_to be_nil
      expect(created.attributes.symbolize_keys).to include(resource_data)
      expect(response.headers['Location']).to eq(
        "http://www.example.com/api/#{pluralized_name}/#{model.first.id}"
      )
    end
  end

  context 'with invalid parameters' do
    let(:resource_data) { invalid_resource }

    it 'does not add a record to db, returns HTTP status 422 with error details' do
      expect(response).to have_http_status :unprocessable_entity
      expect(model.find_by(**resource_data)).to be_nil
      expect(json_body['error']['invalid_params'].symbolize_keys).to(
        include(*invalid_attributes.keys)
      )
    end
  end
end

shared_context 'get resource' do
  let!(:resource) { create(resource_name) }
  let(:id) { resource.id }

  before { get "/api/#{pluralized_name}/#{id}", headers: }
end

shared_examples 'get resource examples' do
  context 'with existing resource' do
    it 'returns the requested resource' do
      expect(response).to have_http_status :ok
      expect(response.body).to eq({ data: resource_presenter.new(resource, {}).fields }.to_json)
    end
  end

  context 'with nonexisting resource' do
    let(:id) { 12_345 }

    it 'returns HTTP status 404' do
      expect(response).to have_http_status :not_found
    end
  end
end

shared_context 'get resources' do
  let(:query) { query_params.any? ? "?#{query_params.map { |k, v| "#{k}=#{v}" }.join('&')}" : '' }
  let(:query_params) { {} }

  before do
    resources
    get "/api/#{pluralized_name}#{query}", headers:
  end
end

shared_examples 'get resources examples' do
  context 'without any parameters' do
    it 'returns all resources' do
      expect(response).to have_http_status :ok
      expect(json_body['data'].count).to eq(model.count)
      expect(json_body['data']).to all(include(*resource_presenter.build_attributes.map(&:to_s)))
    end
  end
end

shared_context 'patch resource' do
  let!(:resource) { create(resource_name, **error_attributes) }
  let(:id) { resource.id }
  let(:params) { { data: corrected_attributes } }

  before { patch "/api/#{pluralized_name}/#{id}", params:, headers: }
end

shared_examples 'patch resource examples' do
  context 'with valid parameters' do
    it 'updates record in the db and returns updated resource' do
      expect(response).to have_http_status :ok
      resource.reload
      expect(resource.attributes.symbolize_keys).to include(corrected_attributes)
      expect(response.body).to eq({ data: resource_presenter.new(resource, {}).fields }.to_json)
    end
  end

  context 'with invalid parameters' do
    let(:params) { { data: invalid_attributes } }

    it 'does not updates the record in the db and returns an error with details' do
      expect(response).to have_http_status :unprocessable_entity
      resource.reload
      expect(json_body['error']['invalid_params'].symbolize_keys).to(
        include(*invalid_attributes.keys)
      )
      resource.reload
      expect(resource.attributes.symbolize_keys).to include(error_attributes)
    end
  end

  context 'with nonexistent resource' do
    let(:id) { 12_345 }

    it 'returns HTTP status 404' do
      expect(response).to have_http_status :not_found
    end
  end
end

shared_context 'delete resource' do
  let!(:resource) { create(resource_name) }
  let(:id) { resource.id }

  before { delete "/api/#{pluralized_name}/#{id}", headers: }
end

shared_examples 'delete resource examples' do
  context 'with existing resource' do
    it 'deletes the record and returns HTTP status 204' do
      expect(response).to have_http_status :no_content
      expect(model.find_by(id: resource.id)).to be_nil
    end
  end

  context 'with nonexistent resource' do
    let(:id) { 12_345 }

    it 'returns HTTP status 404' do
      resource
      expect(response).to have_http_status :not_found
      expect(model.find_by(id: resource.id)).not_to be_nil
    end
  end
end

shared_examples 'fields picking' do |pick_fields:|
  describe 'fields picking' do
    let(:query_params) do
      fields.any? ? { fields: fields.join(',').to_s } : {}
    end

    context 'without the fields parameter' do
      let(:fields) { [] }

      it 'returns all fields specified in resource presenter' do
        expect(response).to have_http_status :ok
        expect(json_body['data']).to all(include(*resource_presenter.build_attributes.map(&:to_s)))
      end
    end

    context 'with the fields parameter' do
      let(:fields) { pick_fields }

      it 'returns only requested fields' do
        expect(response).to have_http_status :ok
        json_body['data'].each do |res|
          expect(res.keys).to eq fields.map(&:to_s)
        end
      end
    end

    context 'with invalid fields names' do
      let(:fields) { %w[foo bar] }

      it 'returns an error with invalid parameters' do
        expect(response).to have_http_status :bad_request
        expect(json_body['error']['invalid_params']).to eq 'fields=foo'
      end
    end
  end
end

shared_examples 'sorting' do |sorting_column:|
  describe 'sorting' do
    let(:query_params) { { sort: column } }
    let(:column) { sorting_column }

    context 'with valid sorting params' do
      it 'returns sorted data' do
        expect(response).to have_http_status :ok
        expect(json_body['data'].map { |res| res[column.to_s] }).to(
          eq(model.order(column).map(&column.to_sym))
        )
      end
    end

    context 'with invalid sorting params' do
      context 'when column name is invalid' do
        let(:query_params) { { sort: :foo, dir: :asc } }

        it 'returns an error with invalid parameters' do
          expect(response).to have_http_status :bad_request
          expect(json_body['error']['invalid_params']).to eq 'sort=foo'
        end
      end

      context 'when sorting direction is invalid' do
        let(:query_params) { { sort: column, dir: :ascending } }

        it 'returns an error with invalid parameters' do
          expect(response).to have_http_status :bad_request
          expect(json_body['error']['invalid_params']).to eq 'dir=ascending'
        end
      end
    end
  end
end

shared_examples 'filtering' do |filtering_column:, predicate:, value:|
  describe 'filtering' do
    context 'with valid filtering param' do
      let(:query_params) { { "q[#{filtering_column}_#{predicate}]" => value } }

      it 'returns filtred data' do
        expect(response).to have_http_status :ok
        expect(json_body['data']).to all(include { filtering_column.to_s => value })
      end
    end

    context 'with invalid filtering param "q[foo_cont]=bar"' do
      let(:query_params) { { 'q[foo_cont]' => 'bar' } }

      it 'returns an error with invalid parameters' do
        expect(response).to have_http_status :bad_request
        expect(json_body['error']['invalid_params']).to eq 'q[foo_cont]=bar'
      end
    end
  end
end

shared_examples 'pagination' do
  describe 'pagination' do
    context 'when asking for the first page' do
      let(:query_params) { { 'page' => 1, 'per' => 2 } }

      it 'returns only two resources' do
        expect(response).to have_http_status :ok
        expect(json_body['data'].count).to eq 2
        expect(response.headers['Link'].split(',').count).to eq 2
      end

      it 'returns the "next" and "last" links' do
        expect(response.headers['Link']).to match(/rel="next"/)
        expect(response.headers['Link']).to match(/rel="last"/)
      end
    end

    context 'when asking for the last page' do
      let(:query_params) { { 'page' => 2, 'per' => 2 } }

      it 'returns only one resource' do
        expect(response).to have_http_status :ok
        expect(json_body['data'].count).to eq 1
      end

      it 'returns the "first" and "prev" links' do
        expect(response.headers['Link']).to match(/rel="first"/)
        expect(response.headers['Link']).to match(/rel="prev"/)
      end
    end

    context 'when asking for the middle page' do
      let(:query_params) { { 'page' => 2, 'per' => 1 } }

      it 'returns all four links' do
        expect(response).to have_http_status :ok
        expect(json_body['data'].count).to eq 1
        expect(response.headers['Link']).to match(/rel="first"/)
        expect(response.headers['Link']).to match(/rel="prev"/)
        expect(response.headers['Link']).to match(/rel="next"/)
        expect(response.headers['Link']).to match(/rel="last"/)
      end
    end

    context 'when asking out of range page' do
      let(:query_params) { { 'page' => 2, 'per' => 3 } }

      it 'returns "first" and "last" links' do
        expect(response).to have_http_status :ok
        expect(json_body['data'].count).to eq 0
        expect(response.headers['Link']).to match(/rel="first"/)
        expect(response.headers['Link']).to match(/rel="last"/)
      end
    end

    context 'when sending invalid parameters' do
      let(:query_params) { { 'page' => 'fake', 'per' => 2 } }

      it 'returns an error with invalid parameters' do
        expect(response).to have_http_status :bad_request
        expect(json_body['error']['invalid_params']).to eq 'page=fake'
      end
    end
  end
end

shared_examples 'embed picking' do |embed:|
  describe 'embed picking' do
    context 'with the "embed" parameter' do
      let(:query_params) { { embed: embed.to_s } }

      it 'returns the resources with embedded' do
        expect(json_body['data']).to all(include embed.to_s)
      end
    end

    context 'with invalid "embed" parameter' do
      let(:query_params) { { embed: 'fake' } }

      it 'returns an error with invalid parameters' do
        expect(response).to have_http_status :bad_request
        expect(json_body['error']['invalid_params']).to eq 'embed=fake'
      end
    end
  end
end
