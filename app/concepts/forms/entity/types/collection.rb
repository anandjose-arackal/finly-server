class Forms::Entity::Types::Collection < Forms::Entity::Base

  register :collection

  option :minimum

  contract do
    optional(:minimum).value(:int?)
  end

  def build
    transformer = Forms::Contracts::Transformer.new(field_key, options, nil, contract_block, collection: true)
    transformer.generate
  end

end