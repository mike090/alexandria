# frozen_string_literal: true

class AccessTokensController < ApplicationController
  before_action :authenticate_user, only: :destroy

  def create
    skip_authorization
    user = User.find_by!(email: login_params[:email])
    if user.authenticate(login_params[:password])
      access_token = create_access_token(user)
      render serialize(access_token, { token: access_token.generate_token }).merge(status: :created)
    else
      render status: :unprocessable_entity, json: { error: { message: 'Invalid credentials.' } }
    end
  end

  def destroy
    authorize access_token
    access_token.destroy
    render status: :no_content
  end

  private

  def login_params
    params.require(:data).permit(:email, :password)
  end

  def create_access_token(user)
    AccessToken.find_by(user:, api_key:).try(:destroy)
    access_token = AccessToken.create(user:, api_key:)
    params[:embed] = params[:embed].present? ? params[:embed].prepend('user,') : 'user'
    access_token
  end
end
