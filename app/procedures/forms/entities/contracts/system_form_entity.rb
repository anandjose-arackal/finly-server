class Forms::Entities::Contracts::SystemFormEntity < Forms::Entities::Contracts::BaseFormEntity

  property :system_field, deserializer: -> (input, represented, *args) {represented.system_field = true}
end
