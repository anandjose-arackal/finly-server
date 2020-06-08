class Forms::Contracts::Builders::Form

  def self.call(form, user)
    form  = Form.where(uuid: form.uuid).includes(:entities, {sections: {entities: [:compute_lookup_entity, :form, {conditions: :actions}, :validations, {entities: [:compute_lookup_entity, :form, {conditions: :actions}, :validations, {entities: [:compute_lookup_entity, :form, {conditions: :actions}, :validations, entities: [:compute_lookup_entity, :form, {conditions: :actions}, :validations, :entities]]}]}]}}).first
    # FixMe : proper inclusion of conditions, validations and dependencies to avoid N+1
    sections = form.sections
    Class.new(Reform::Form) do

      if form.model.has_attribute?(:created_by)
        property :created_by, deserializer: -> (input, represented, **) do
          represented.created_by = RequestStoreUtil.current_user if represented.created_by.blank?
        end
      end

      if form.model.has_attribute?(:company_id)
        property :company_id, deserializer: -> (input, represented, **) do
          represented.company_id = RequestStoreUtil.current_user.company_id if represented.company_id.blank?
        end
      end

      associate_custom_fields = false
      sections.each do |section|
        associate_custom_fields ||= section.associate_custom_fields
        section.entities.each do |entity|

          # Only root entities
          next unless entity.parent_id.blank?

          Forms::Contracts::Builders::Form.setup_entity self, entity, user
        end
      end

      Forms::Contracts::Builders::CustomField.(self, form.entities.root.custom_fields) if associate_custom_fields.present?
    end
  end

  def self.setup_entity(contract_klass, entity, user)
    if entity.entities.present? and not entity.class.collection?
      entity.entities.each do |ent|
        setup_entity(contract_klass, ent, user)
      end
    else
      entity.contract(contract_klass, user)
    end
  end

end