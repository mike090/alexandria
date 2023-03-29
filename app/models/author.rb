# frozen_string_literal: true

class Author < ApplicationRecord
  include PgSearch::Model

  multisearchable against: %i[given_name family_name]

  validates :given_name, :family_name, presence: true

  has_many :books
end
