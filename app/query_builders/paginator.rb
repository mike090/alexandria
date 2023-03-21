# frozen_string_literal: true

class Paginator
  def initialize(scope, query_params, url)
    @query_params = query_params
    @page = validate_param!('page', 1)
    @per = validate_param!('per', 10)
    @scope = scope.page(@page).per(@per)
    @url = url
  end

  def paginate
    @scope.page(@page).per(@per)
  end

  def links
    @links ||= pages.each_with_object([]) do |(k, v), links|
      query_params = @query_params.merge({ 'page' => v, 'per' => @per }).to_param
      links << "<#{@url}?#{query_params}>; rel=\"#{k}\""
    end.join(', ')
  end

  private

  def pages
    @pages || {}.tap do |pgs|
      pgs[:first] = 1 unless @scope.first_page?
      pgs[:prev] = @scope.prev_page if @scope.prev_page
      pgs[:next] = @scope.next_page if @scope.next_page
      pgs[:last] = @scope.total_pages unless @scope.last_page?
    end
  end

  def validate_param!(name, default)
    return default unless @query_params[name]

    unless @query_params[name] =~ /\A\d+\z/
      raise QueryBuilderError.new("#{name}=#{@query_params[name]}"),
            'Invalid Pagination params. Only numbers are supported for "page" and "per".'
    end
    @query_params[name]
  end
end
