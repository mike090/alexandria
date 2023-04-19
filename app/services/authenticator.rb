# frozen_string_literal: true

class Authenticator
  include ActiveSupport::SecurityUtils

  def initialize(authorization)
    @authorization = authorization
  end

  def api_key
    @api_key ||= compute_api_key
  end

  def access_token
    @access_token ||= compute_access_token
  end

  private

  def compute_api_key
    return nil unless credentials['api_key']&.all?

    id = credentials.dig('api_key', 'id')
    api_key = ApiKey.activated.find_by(id:)
    api_key if api_key && secure_compare_with_hashing(api_key.key, credentials.dig('api_key', 'key'))
  end

  def compute_access_token
    return nil unless api_key && credentials['access_token'].values.all?

    user_id = credentials.dig('access_token', 'user_id')
    access_token = AccessToken.find_by(user_id:, api_key:)
    return nil unless access_token

    if access_token.expired?
      access_token.destroy
      return nil
    end

    access_token if access_token.authenticate(credentials.dig('access_token', 'token'))
  end

  def access_token_expired?(access_token)
    return false unless access_token.expired?
  end

  def credentials
    @credentials ||= begin
      nil_cedentials =
        { 'api_key' => { 'id' => nil, 'key' => nil }, 'access_token' => { 'user_id' => nil, 'token' => nil } }
      nil_cedentials.deep_merge(
        @authorization.scan(/(\w+)[:=] ?"?([\w|:]+)"?/).to_h.slice(*nil_cedentials.keys).to_h do |key, values|
          [key, nil_cedentials[key].keys.zip(values.split(':')).to_h]
        end
      )
    end
  end

  def secure_compare_with_hashing(val_a, val_b)
    secure_compare(Digest::SHA1.hexdigest(val_a), Digest::SHA1.hexdigest(val_b))
  end
end
