# frozen_string_literal: true

class Filter
  PREDICATES = {
    'eq' => ->(column, value) { [{ column => value }] },
    'cont' => ->(column, value) { ["#{column} LIKE ?", "%#{value}%"] },
    'notcont' => ->(column, value) { ["#{column} NOT LIKE ?", "%#{value}%"] },
    'start' => ->(column, value) { ["#{column} LIKE ?", "#{value}%"] },
    'end' => ->(column, value) { ["#{column} LIKE ?", "%#{value}"] },
    'lt' => ->(column, value) { ["#{column} < ?", value] },
    'gt' => ->(column, value) { ["#{column} > ?", value] }
  }.freeze

  def initialize(scope, params)
    @scope = scope
    @presenter = "#{@scope.model}Presenter".constantize
    @filters = params['q'] || {}
  end

  def filter
    return @scope unless @filters.any?

    applay_filters
  end

  private

  def parsed_filters
    @parsed_filters ||=
      @filters.each_with_object({}) do |(key, value), result|
        filter_data = {
          value:,
          column: key.split('_')[0...-1].join('_'),
          predicate: key.split('_').last
        }
        validate_filter(key, filter_data)
        result[key] = filter_data
      end
  end

  def applay_filters
    scope = @scope
    parsed_filters.each do |_key, data|
      predicate = data[:predicate]
      clause = PREDICATES[predicate].call(data[:column], data[:value])
      scope =  scope.where(*clause)
    end
    scope
  end

  def validate_filter(key, data)
    error!(key, data) unless @presenter.filter_attributes.include? data[:column]
    error!(key, data) unless PREDICATES.keys.include? data[:predicate]
  end

  def error!(key, data)
    columns = @presenter.filter_attributes.join(',')
    pred = PREDICATES.keys.join(',')
    raise QueryBuilderError.new("q[#{key}]=#{data[:value]}"),
          "Invalid Filter params. Allowed columns: (#{columns}), 'predicates': #{pred}"
  end
end
