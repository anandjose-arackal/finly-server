class Forms::Entities::Ops::Update < Transactions::API

  schema do
    params do
      required(:field_type).value(included_in?: Forms::Entity::Registry.types.keys)
    end
  end

  step Model(FormEntity, :find_by_uuid)

  step Policy::Pundit(Forms::Entities::Policy, :update?)
  # step :set_custom_field
  step Contract::Build(builder: :build_contract)
  step Contract::Validate()
  step Contract::Persist()

  def set_custom_field(options, params:, **)
    params[:custom_field] = true
    true
  end

  def build_contract(options, params:, model:, **)
    field_type = params['field_type']
    Forms::Definitions::Registry.types[field_type].new(model)
  end

end