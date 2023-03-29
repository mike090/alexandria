# frozen_string_literal: true

class Publisher < ApplicationRecord
  include PgSearch::Model

  multisearchable against: [:name]

  validates :name, presence: true

  has_many :books
end
