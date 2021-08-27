class Masters::Schema::Records::Ops::Index < Masters::Schema::Records::Base

  schema do
    params do
      required(:master_key).filled
    end
  end

  # This is defined in base class
  step RecordModelClass()
  step Policy::Pundit(Masters::Schema::Records::Policy, :index?)
  step Resolver::Transactions::Load(klass: Masters::Schema::Records::Resolver, paginate: true)

end