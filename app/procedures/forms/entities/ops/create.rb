class Forms::Entities::Ops::Create < Transactions::API

  schema do
    params do
      required(:form_entity) do
        hash do
          required(:entity_type).filled
        end
      end
    end
  end

  step :retrieve_model

  def retrieve_model(options, params:, **)
    options[:model] = Forms::Entity::Registry.types[params[:form_entity][:entity_type]].new
    true
  end

  step Policy::Pundit(Forms::Entities::Policy, :create?)

  step Contract::Build(builder: :retrieve_contract!)

  step Contract::Validate(key: :form_entity)

  step :check_success

  step Contract::Persist()

  fail :check_failure

  # Helper methods
  def check_success(ctx, options)
    true
  end
  def check_failure(ctx, options)
    true
  end


  def retrieve_contract!(options, model:, current_user:, **)
    model.class.contract(model, current_user)
  end
end