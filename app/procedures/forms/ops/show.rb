class Forms::Ops::Show < Transactions::API

  step Model(Form, :find_by_uuid)
  step Policy::Pundit(Forms::Policy, :show?)
  # step Transactions::Authorization::Roles(:admin)

end