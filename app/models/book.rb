# frozen_string_literal: true

class Book < ApplicationRecord
  include PgSearch::Model

  multisearchable against: %i[title subtitle description]

  validates :title, :released_on, :author, presence: true

  validates :isbn_10, presence: true, length: { is: 10 }, uniqueness: true
  validates :isbn_13, presence: true, length: { is: 13 }, uniqueness: true

  belongs_to :publisher, required: false
  belongs_to :author

  mount_base64_uploader :cover, CoverUploader
end
