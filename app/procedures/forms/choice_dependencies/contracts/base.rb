class Forms::ChoiceDependencies::Contracts::Base < Reform::Form

  property :id
  property :current_user, virtual: true
  property :company_id, deserializer: -> (input, represented, *args) {represented.company_id = represented.contract_root.current_user.company_id}
  property :form_id, deserializer: -> (input, represented, *args) {represented.form_id = input[:form_id] if represented.form_id.blank?}

  property :dependent_entity_id, deserializer: -> (input, represented, *args) {represented.dependent_entity_id = input[:dependent_entity_id] if represented.dependent_entity_id.blank?}
  property :controlling_entity_id, deserializer: -> (input, represented, *args) {represented.controlling_entity_id = input[:controlling_entity_id] if represented.controlling_entity_id.blank?}
  property :custom #todo - doubt
  property :is_updated, deserializer: -> (input, represented, *args) {represented.is_updated = true if represented.model.persisted? } # property :can_be_updated # todo - doubt
  property :created_by_id, deserializer: -> (input, represented, *args) {represented.created_by_id = represented.contract_root.current_user.id if represented.created_by_id.blank? or not represented.model.persisted? }
  property :updated_by_id, deserializer: -> (input, represented, *args) {represented.updated_by_id = represented.contract_root.current_user.id }
  # property :internal #todo - doubt


  collection :mappings, populate_if_empty: FormChoiceDependencyMapping, populator: :mappings! do
    property :id
    property :_destroy, virtual: true
    # property :dependency_id, deserializer: -> (input, represented, *args){represented.dependency_id = represented.contract_root.id}
    property :dependent_choice_id
    property :controlling_choice_id
  end

  # property :internal, deserializer: -> (input, represented, *args) {debugger}

  def mappings!(collection:, fragment:, index:, options:, **)
    mapping = mappings.find {|mapping| mapping.id.to_s == fragment["id"].to_s}

    if fragment["_destroy"]
      mappings.destroy(mapping)
      return skip!
    end

    mapping || mappings.append(FormChoiceDependencyMapping.new)
  end
end