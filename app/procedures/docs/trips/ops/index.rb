class Docs::Trips::Ops::Index < Transactions::API

  step Resolver::Transactions::Load(model: Trip, paginate: true)

end