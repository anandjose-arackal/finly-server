class Forms::Entities::Ops::Update < Transactions::API

  schema do
    params do
      required(:form_entity) do
        hash do
          required(:type).filled
        end
      end
    end
  end

  step Model(FormEntity, :find_by_uuid)

  step Policy::Pundit(Forms::Entities::Policy, :update?)

  step :check_success

  step Contract::Build(builder: :build_contract!)

  step Contract::Validate(key: :form_entity)

  step Contract::Persist()

  fail :check_failure

  # Helper methods
  def check(ctx, options)
    true
  end
  def check_failure(ctx, options)
    true
  end

  def build_contract!(options, model:, current_user:, **)
    model.class.contract(model, current_user)
  end

end