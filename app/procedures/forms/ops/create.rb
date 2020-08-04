class Forms::Ops::Create < Transactions::API

  schema do
    params do
      required(:field_type).value(included_in?: Forms::Entity::Registry.types.keys)
    end
  end

  step Model(Form, :find_by_uuid)
  step Policy::Pundit(Forms::Policy, :create?)
  step :set_custom_field
  step Contract::Build(builder: :build_contract)
  step Contract::Validate()
  step Contract::Persist()


  # Remvoed it after renaming custom_field to system_field
  # def set_custom_field(options, params:, **)
  #   params[:custom_field] = true
  #   true
  # end

  def build_contract(options, params:, model:, **)
    field_type = params['field_type']
    Forms::Definitions::Registry.types[field_type].new(model)
  end

end