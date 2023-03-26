# frozen_string_literal: true

class BooksController < ApplicationController
  def index
    books = orchestrate_query(Book.all)
    serializer = Alexandria::Serializer.new(
      data: books, params: params.to_unsafe_hash, actions: %i[fields embeds]
    )

    render json: serializer.to_json
  end
end
