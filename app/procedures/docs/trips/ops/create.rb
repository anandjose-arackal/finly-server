class Docs::Trips::Ops::Create < Transactions::API

  step Resolver::Transactions::Load(model: Trip, paginate: true)

end