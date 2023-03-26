# frozen_string_literal: true

class EmbedPicker
  def initialize(presenter)
    @presenter = presenter
  end

  def embed
    return @presenter unless embeds.any?

    embeds.each { |embed| @presenter.data[embed] = build_embed(embed) }
    @presenter
  end

  def embeds
    @embeds ||= validate_embeds
  end

  private

  def validate_embeds
    return [] if @presenter.params[:embed].blank?

    @presenter.params[:embed].split(',').each do |embed|
      error!(embed) unless @presenter.class.relations.include? embed
    end
  end

  def error!(embed)
    raise RepresentationBuilderError.new("embed=#{embed}"),
          "Invalid Embed. Allowed relations: (#{@presenter.class.relations.join(',')})"
  end

  def build_embed(embed)
    entity = @presenter.object.send(embed)
    return entity unless entity

    if relations[embed].collection?
      entity.order(:id).map { |item| FieldPicker.new(embed_presenter(embed, item)).pick.data }
    else
      FieldPicker.new(embed_presenter(embed, entity)).pick.data
    end
  end

  def embed_presenter(model, object)
    "#{relations[model].class_name}Presenter".constantize.new(object, {})
  end

  def relations
    @relations ||= @presenter.object.class.reflect_on_all_associations.to_h do |association|
      [association.name.to_s, association]
    end
  end
end
