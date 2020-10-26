class Forms::Entities::Ops::Show < Transactions::API

  step Model(FormEntity, :find_by_uuid)
  step Policy::Pundit(Forms::Policy, :show?)
  # step Transactions::Authorization::Roles(:admin)

end