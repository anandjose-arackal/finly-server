class Docs::Trips::Ops::Create < Transactions::API

  step Model(Trip, :new)

end