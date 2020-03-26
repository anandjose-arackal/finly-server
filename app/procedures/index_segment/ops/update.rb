class IndexSegment::Ops::Update < Transactions::API

  step Model(IndexViewSegment, :find_by_uuid)
  step Policy::Pundit(IndexSegment::Policy, :update?)
  step Contract::Build(constant: IndexSegment::Contracts::Update)
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('View saved')

end