class Masters::Schema::Ops::Index < Transactions::API

  step Policy::Pundit(Masters::Schema::Policy, :index?)
  step Resolver::Transactions::Load(route: 'master_schemas.default', paginate: true)

end