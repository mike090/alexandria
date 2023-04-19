# frozen_string_literal: true

class AccessToken < ApplicationRecord
  belongs_to :user
  belongs_to :api_key

  validates :user, presence: true
  validates :api_key, presence: true

  def authenticate(unencrypted_token)
    BCrypt::Password.new(token_digest).is_password?(unencrypted_token)
  end

  def expired?
    created_at.since(14.days).past?
  end

  def generate_token
    token = SecureRandom.hex
    digest = BCrypt::Password.create(token, cost: BCrypt::Engine.cost)
    update_column(:token_digest, digest)
    token
  end
end
