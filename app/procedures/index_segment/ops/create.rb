class IndexSegment::Ops::Create < Transactions::API

  step Model(IndexViewSegment, :new)
  step Policy::Pundit(IndexSegment::Policy, :create?)
  step AssignModelUser()
  step Contract::Build(constant: IndexSegment::Contracts::Create)
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('View saved')

end