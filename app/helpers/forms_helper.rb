module FormsHelper
  def form_data(form, model = self)
    form.entities.root.reduce({}) do |acc, entity|
      acc.merge(entity_data(model, entity)).with_indifferent_access
    end
  end

  private

  def entity_data(model, form_entity)
    form_data = {}

    if form_entity.class.collection?
      collection_models = (model.respond_to?(form_entity.entity_key) && model.send(form_entity.entity_key)) || []
      collection_data = collection_models.map do |collection_model|
        if collection_model.respond_to?(:forms_extra_data)
          collection_model_data = collection_model.send(:forms_extra_data)
          entities_data = form_entity.entities.reduce({}) {|acc, ent| acc.merge(entity_data(collection_model, ent))}.merge(id: collection_model.id, collection_id: collection_model.id)
          entities_data.merge(collection_model_data)
        else
          form_entity.entities.reduce({}) {|acc, ent| acc.merge(entity_data(collection_model, ent))}.merge(id: collection_model.id, collection_id: collection_model.id)
        end
      end
      form_data.merge!(form_entity.entity_key => collection_data)
    elsif form_entity.entities.present?
      form_entity.entities.each do |entity|
        if entity.system_field && model.respond_to?(entity.entity_key)
          form_data.merge!({entity.entity_key => model.send(entity.entity_key)})
        else
          if model.respond_to?(:form_custom_fields)
            value = model.form_custom_fields.joins(:form_entity).where("form_entities.entity_key = ?", entity.entity_key).first&.retrieve_value
            form_data.merge!({entity.entity_key => value})
          end
        end
      end
    else
      if form_entity.system_field && model.respond_to?(form_entity.entity_key)
        form_data.merge!({form_entity.entity_key => model.send(form_entity.entity_key)})

        if [:lookup, 'lookup'].include?(form_entity.entity_type)
          puts "****************************************"
          puts model.send(:forms_extra_data, form_entity.entity_type, form_entity.entity_key)
          puts "****************************************"
          form_data.merge!(model.send(:forms_extra_data, form_entity.entity_type, form_entity.entity_key))
        end

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
