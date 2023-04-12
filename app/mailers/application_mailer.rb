# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'admin@alexandria.com'
  layout 'mailer'
end
