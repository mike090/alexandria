# frozen_string_literal: true

class FieldPicker
  def initialize(presenter)
    @presenter = presenter
    # @fields = @presenter.params[:fields]
  end

  def pick
    fields.each do |field|
      value = (@presenter.respond_to?(field) ? @presenter : @presenter.object).send field
      @presenter.data[field] = value
    end
    @presenter
  end

  def fields
    @fields ||= validate_fields
  end

  private

  def validate_fields
    return pickable if @presenter.params[:fields].blank?

    @presenter.params[:fields].split(',').each_with_object([]) do |field, result|
      error!(field) unless pickable.include? field
      result << field
    end
  end

  def error!(field)
    raise RepresentationBuilderError.new("fields=#{field}"),
          "Invalid Field Pick. Allowed fields: (#{@presenter.class.build_attributes.join { ',' }})"
  end

  def pickable
    @pickable ||= @presenter.class.build_attributes
  end
end
