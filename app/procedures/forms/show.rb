class Forms::Show < Transactions::API

  step Model(Form, :find)
  step Transactions::Authorization::Roles(:admin)

end