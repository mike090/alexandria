# frozen_string_literal: true

class Sorter
  DIRECTIONS = %w[asc desc].freeze

  def initialize(scope, params)
    @scope = scope
    @presenter = "#{@scope.model}Presenter".constantize
    @column = params['sort']
    @direction = params['dir'] || 'asc'
  end

  def sort
    return @scope unless @column

    error!('sort', @column) unless @presenter.sort_attributes.include? @column
    error!('dir', @direction) unless DIRECTIONS.include? @direction
    @scope.order("#{@column} #{@direction}")
  end

  private

  def error!(name, value)
    columns = @presenter.sort_attributes.join(',')
    raise QueryBuilderError.new("#{name}=#{value}"),
          "Invalid sorting params. sort: (#{columns}), dir: #{DIRECTIONS.join(',')}"
  end
end
