class Forms::DSL::Entity::Types::Collection < Forms::DSL::Entity::Base

  register :collection

  option :minimum

  contract do
    optional(:minimum).value(:int?)
  end

  # Todo - Deprecated since we are generating the forms from database.
  # Todo - This was old implementation of generating forms directly from class
  # def builder_args
  #   [field_key, schema, {}, contract_block, collection: true]
  # end

end