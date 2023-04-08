# frozen_string_literal: true

shared_context 'authentication' do
  let(:headers) do
    api_key = ApiKey.create
    { 'HTTP_AUTHORIZATION' => "Alexandria-Token api_key=#{api_key.id}:#{api_key.key}" }
  end
end
