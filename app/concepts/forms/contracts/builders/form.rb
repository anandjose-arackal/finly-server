class Forms::Contracts::Builders::Form

  def self.call(form, user)
    # FixMe : proper inclusion of conditions, validations and dependencies to avoid N+1
    sections = form.sections.includes(entities: {entities: {entities: {entities: [:entities]}}})
    Class.new(Forms::Contracts::Base) do

      Forms::Contracts::Helpers::SetupBase.(self)

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
        section.entities.root.each do |entity|

          Forms::Contracts::Builders::Form.setup_entity self, entity, user
          # If the entity has sub-entities and is not a collection, then define the properties without wrapping in the entity
          # Fixme: This has to be generalized
          # if entity.entities.present? and not entity.class.collection?
          #   entity.entities.each do |ent|
          #     ent.contract(self, user)
          #   end
          # else
          #   entity.contract(self, user)
          # end
        end
      end

      Forms::Contracts::Builders::CustomField.(self, form.entities.root.custom_fields) if associate_custom_fields.present?

      # dependencies.each do |dependency|
      #   class_eval &dependency.contract
      # end
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