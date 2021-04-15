module FormsHelper
  include ActiveSupport::Concern

  def form_data(form, model = self)
    form.entities.root.includes({entities: {entities: {entities: :entities}}}).reduce({}) do |acc, entity|
      acc.merge(entity_data(model, entity)).with_indifferent_access
    end
  end


  def form_metadata
    return @form_metadata if @form_metadata.present?

    return {} if (form_klass = self.form_klass).nil?
    form_klass = Object.const_get(form_klass)
    meta = form_klass.try(:meta)
    return {} unless meta.present?

    @form_metadata = LiquidHelper.interpolate(meta, { 'record' => self.to_exposure })
  end

  def form_klass
    self.class.name
  end

  def form
    raise 'Could not retrieve form' if self.company_id.blank?

    Form.find_by(klass_name: form_klass, company_id: self.company_id)
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
          form_data.merge!({ entity.entity_key => model.send(entity.entity_key) })
        else
          if model.respond_to?(:form_custom_fields)
            value = model.form_custom_fields.joins(:form_entity).where("form_entities.entity_key = ?", entity.entity_key).first&.retrieve_value
            form_data.merge!({ entity.entity_key => value })
          end
        end
      end
    else
      if form_entity.system_field && model.respond_to?(form_entity.entity_key)
        form_data.merge!({form_entity.entity_key => model.send(form_entity.entity_key)})
        if form_entity.entity_type == 'dropdown' || form_entity.entity_type == 'lookup'
          form_data.merge!({"#{form_entity.entity_key}_value" => model.retrieve_value(form_entity)})
        end
      else
        if model.respond_to?(:form_custom_fields)
          custom_field = model.form_custom_fields.joins(:form_entity).where("form_entities.entity_key = ?", form_entity.entity_key).order(:created_at).last
          value = custom_field&.retrieve_value
          form_data.merge!({form_entity.entity_key => value})
          if form_entity.entity_type == 'dropdown' || form_entity.entity_type == 'lookup'
            form_data.merge!({"#{form_entity.entity_key}_value" => custom_field&.selected_choice})
          end
        end
      end
    end
    form_data
  end
end
