class Forms::Fields::Create < Transaction

  step Model(FormField, :new)
  step Contract::Build(constant: Forms::Fields::Contract::Create)
  step Contract::Validate()
  step Contract::Persist()

end