# frozen_string_literal: true

class PasswordReset
  include ActiveModel::Model

  attr_accessor :email, :reset_password_redirect_url, :reset_token, :password, :updating

  validates :email, presence: true, unless: :updating
  validates :reset_password_redirect_url, presence: true, unless: :updating
  validates :password, presence: true, if: :updating

  def create
    user && valid? && user.init_password_reset(reset_password_redirect_url)
  end

  def redirect_url
    build_redirect_url
  end

  def update
    self.updating = true
    user && valid? && user.complete_password_reset(password)
  end

  def user
    @user ||= begin
      user = User.find_by(email:) || User.find_by(reset_password_token: reset_token)
      raise ActiveRecord::RecordNotFound unless user

      user
    end
  end

  private

  def build_redirect_url
    url = user.reset_password_redirect_url
    query_params = Rack::Utils.parse_query(URI(url).query)
    query_params.any? ? "#{url}&reset_token=#{reset_token}" : "#{url}?reset_token=#{reset_token}"
  end
end
