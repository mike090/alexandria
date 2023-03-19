# frozen_string_literal: true

class AddCoverToBooks < ActiveRecord::Migration[7.0]
  def change
    add_column :books, :cover, :string
  end
end
