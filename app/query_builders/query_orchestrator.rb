# frozen_string_literal: true

class QueryOrchestrator
  ACTIONS = %i[paginate sort filter eager_load].freeze

  def initialize(scope:, params:, request:, response:, actions: :all)
    @scope = scope
    @params = params
    @request = request
    @response = response
    @actions = actions == :all ? ACTIONS : actions
  end

  def run
    @run_scope = @scope
    @actions.each do |action|
      raise InvalidBuilderAction, "#{action} not permitted." unless ACTIONS.include? action

      @run_scope = send action
    end

    @run_scope
  end

  private

  def paginate
    current_url = "#{@request.base_url}#{@request.path}"
    paginator = Paginator.new(@run_scope, @params, current_url)
    @response.headers['Link'] = paginator.links
    paginator.paginate
  end

  def sort
    Sorter.new(@run_scope, @params).sort
  end

  def filter
    Filter.new(@run_scope, @params).filter
  end

  def eager_load
    EagerLoader.new(@run_scope, @params).load
  end
end
