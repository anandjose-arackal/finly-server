class Forms::Fields::Create < Transactions::API

  step Model(FormField, :new)
  step Contract::Build(constant: Forms::Fields::Contract::Create)
  step Contract::Validate()
  step Contract::Persist()

end