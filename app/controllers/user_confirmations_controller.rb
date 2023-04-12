# frozen_string_literal: true

class UserConfirmationsController < ActionController::API
  before_action :confirmation_token_not_found

  def show
    user.confirm

    if user.confirmation_redirect_url
      redirect_to user.confirmation_redirect_url, allow_other_host: true
    else
      render plain: 'You are now conformated!'
    end
  end

  private

  def confirmation_token_not_found
    render status: 404, plain: 'Token not found' unless user
  end

  def confirmation_token
    @confirmation_token ||= params[:confirmation_token]
  end

  def user
    @user ||= User.where(confirmation_token:).first
  end
end
