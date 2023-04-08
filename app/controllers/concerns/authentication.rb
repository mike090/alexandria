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

  def unauthorized!(realm)
    headers['WWW-Authenticate'] = %(#{AUTH_SCHEME} realm="#{realm}")
    render status: 401
  end

  def authorization_request
    @authorization_request ||= request.authorization.to_s
  end

  def credentials
    @credentials ||= authorization_request.scan(/(\w+)[:=] ?"?([\w|:]+)"?/).to_h
  end

  def api_key
    return nil if credentials['api_key'].blank?

    id, key = credentials['api_key'].split(':')
    api_key = id && key && ApiKey.activated.find_by(id:)

    return api_key if api_key && secure_compare_with_hashing(api_key.key, key)
  end

  def secure_compare_with_hashing(val_a, val_b)
    secure_compare(Digest::SHA1.hexdigest(val_a), Digest::SHA1.hexdigest(val_b))
  end
end
