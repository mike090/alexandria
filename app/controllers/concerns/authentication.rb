# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern
  include ActiveSupport::SecurityUtils

  AUTH_SCHEME = 'Alexandria-Token'

  included do
    before_action :validate_auth_scheme
    before_action :authenticate_client
  end

  private

  def validate_auth_scheme
    unauthorized!('Client Relam') unless authorization_request.match(/^#{AUTH_SCHEME} /)
  end

  def authenticate_client
    unauthorized!('Client Relam') unless api_key
  end

  def authenticate_user
    unauthorized!('User Relam') unless access_token
  end

  def unauthorized!(realm)
    headers['WWW-Authenticate'] = %(#{AUTH_SCHEME} realm="#{realm}")
    render status: 401
  end

  def authorization_request
    @authorization_request ||= request.authorization.to_s
  end

  def authenticator
    @authenticator ||= Authenticator.new(authorization_request)
  end

  def api_key
    @api_key ||= authenticator.api_key
  end

  def access_token
    @access_token ||= authenticator.access_token
  end

  def current_user
    @current_user ||= access_token.try(:user)
  end
end
