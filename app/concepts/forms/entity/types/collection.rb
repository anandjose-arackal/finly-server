class Forms::Entity::Types::Collection < Forms::Entity::Base

  register :collection

  option :minimum

  contract do
    optional(:minimum).value(:int?)
  end

  def builder_args
    [field_key, schema, {}, contract_block, collection: true]
  end

end