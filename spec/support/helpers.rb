# frozen_string_literal: true

module Helpers
  def json_body
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include Helpers
end
