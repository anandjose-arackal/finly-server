class Forms::Ops::EntityConfig < Transactions::API

  schema do
    params do
      required(:entity_id)
    end
  end

  pass :find_model
  step Policy::Pundit(Forms::Policy, :entity_config?)

  def find_model(context, params:, current_user:, **)
    context[:model] = FormEntity.find_by(uuid: params[:entity_id])
  end
end