class Forms::Entities::Ops::Create < Transactions::API

  # schema do
  #   params do
  #     required(:field_type).value(included_in?: Forms::Entity::Registry.types.keys)
  #   end
  # end

  step :retrieve_model

  def retrieve_model(options, params:, **)
    case params[:form_entity_type]
    when "text"
      options['model'] = FormEntity::Text.new
    else
      options['model'] = FormEntity::Text.new
    end
    true
  end

  step Policy::Pundit(Forms::Entities::Policy, :create?)

  step Contract::Build(builder: :retrieve_contract!)

  step :check
  def check(ctx, options)
    true
  end



  step Contract::Validate(key: :form_entity)

  step Contract::Persist()

  fail :x
  def x(ctx, options)
    debugger

  end

  def set_custom_field(options, params:, **)
    params[:custom_field] = true
    true
  end

  def retrieve_contract!(options, params:, model:, current_user:, **)
    field_type = params['form_entity_type']

    #todo - pick from right source
    if field_type == 'text'
      Forms::Entities::Contracts::Text.new(model, current_user: current_user)
    end
  end
end