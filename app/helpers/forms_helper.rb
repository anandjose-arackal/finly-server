module FormsHelper
  def form_data(form, model = self)
    form.entities.root.reduce({}) {|acc, entity| acc.merge(entity_data(model, entity))}
  end

  private

  def entity_data(model, form_entity)
    form_data = {}
    if form_entity.entities.present?
      collection_models = (model.respond_to?(form_entity.entity_key) && model.send(form_entity.entity_key)) || []
      collection_data = collection_models.map do |collection_model|
        form_entity.entities.reduce({}) {|acc, ent| acc.merge(entity_data(collection_model, ent))}.merge(id: collection_model.id, collection_id: collection_model.id)
      end
      form_data.merge!(form_entity.entity_key => collection_data)
    else
      if form_entity.system_field && model.respond_to?(form_entity.entity_key)
        form_data.merge!({form_entity.entity_key => model.send(form_entity.entity_key)})
      else
        if model.respond_to?(:form_custom_fields)
          value = model.form_custom_fields.joins(:form_entity).where("form_entities.entity_key = ?", form_entity.entity_key).first&.retrieve_value
          form_data.merge!({form_entity.entity_key => value})
        end
      end
    end
    form_data
  end
end
