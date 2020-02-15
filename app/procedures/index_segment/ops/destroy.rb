class IndexSegment::Ops::Destroy < Transactions::API

  step Model(IndexViewSegment, :find_by_uuid)
  step Policy::Pundit(IndexSegment::Policy, :destroy?)
  step ModelDestroy()
  step Transactions::Messages::SuccessMessage('View removed')

end