# frozen_string_literal: true

class UserMailer < ApplicationMailer
  after_action :fix_sent_time

  def confirmation_email(user)
    @user = user
    mail to: @user.email, subject: 'Confirm your Account!'
  end

  def reset_password(user)
    @user = user
    mail to: @user.email, subject: 'Reset your password'
  end

  private

  def fix_sent_time
    @user.update_column(:confirmation_sent_at, Time.now)
  end
end
