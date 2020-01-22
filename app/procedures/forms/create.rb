class Forms::Create < Transactions::API

  schema do
    params do
      required(:field_type).value(inclusion?: Forms::Entity::Registry.types.keys)
    end
  end

  step Model(Form, :find_by_uuid)
  step Policy::Pundit(Forms::Policy, :create?)
  step :set_custom_field
  step Contract::Build(builder: :build_contract)
  step Contract::Validate()
  step Contract::Persist()

  def set_custom_field(options, params:, **)
    params[:custom_field] = true
    true
  end

  def build_contract(options, params:, **)
    field_type = params['field_type']
    Forms::Definitions::Registry.types[field_type].new
  end

end