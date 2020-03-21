class IndexSegment::Ops::Index < Transactions::API

  schema do
    params do
      required(:screen).filled
    end
  end

  step Resolver::Transactions::Load(model: IndexViewSegment)

end