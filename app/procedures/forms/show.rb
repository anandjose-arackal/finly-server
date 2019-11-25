class Forms::Show < Transactions::API

  step Model(Form, :find_by_uuid)
  step Transactions::Authorization::Roles(:admin)

end