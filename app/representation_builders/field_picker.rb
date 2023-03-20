# frozen_string_literal: true

class FieldPicker
  def initialize(presenter)
    @presenter = presenter
    @fields = @presenter.params[:fields]
  end

  def pick
    (validated_fields || pickable).each do |field|
      value = (@presenter.respond_to?(field) ? @presenter : @presenter.object).send field
      @presenter.data[field] = value
    end
    @presenter
  end

  private

  def validated_fields
    return nil if @fields.blank?

    validated = @fields.split(',') & pickable
    validated.any? ? validated : nil
  end

  def pickable
    @pickable ||= @presenter.class.build_attributes
  end
end
