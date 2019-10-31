class Forms::Entity::Index < Transactions::API

  schema do
    params do
      required(:form_id).filled
    end
  end

  step Transactions::Authorization::Roles(:admin)
  step Transactions::Resolver::Model(FormEntity, filter: true)

end