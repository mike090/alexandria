# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from QueryBuilderError, with: :builder_error
  rescue_from RepresentationBuilderError, with: :builder_error

  protected

  def builder_error(error)
    render status: 400, json: {
      error: {
        message: error.message,
        invalid_params: error.invalid_params
      }
    }
  end

  def orchestrate_query(scope, actions = :all)
    QueryOrchestrator.new(
      scope:,
      params: params.to_unsafe_hash,
      request:,
      response:,
      actions:
    ).run
  end
end
