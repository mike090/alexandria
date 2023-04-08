# frozen_string_literal: true

module ResourceHelpers
  def pluralized_name
    @pluralized_name ||= resource_name.to_s.pluralize
  end

  def resource_presenter
    @resource_presenter ||= "#{resource_name}_presenter".classify.constantize
  end

  def model
    @model ||= resource_name.to_s.classify.constantize
  end

  def invalid_resource
    @invalid_resource ||= attributes_for(resource_name).merge(invalid_attributes)
  end

  def invalid_attributes
    @invalid_attributes ||= attributes_for "invalid_#{resource_name}_attributes"
  end

  def error_attributes
    @error_attributes ||= attributes_for "error_#{resource_name}_attributes"
  end

  def corrected_attributes
    @corrected_attributes ||= error_attributes.to_h { |key, _value| [key, attributes_for(resource_name)[key]] }
  end

  def resources
    send(pluralized_name.to_sym)
  end
end
