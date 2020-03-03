class IndexSegment::Ops::Update < Transactions::API

  step Model(IndexViewSegment, :find_by_uuid)
  step Policy::Pundit(IndexSegment::Policy, :update?)
  step Contract::Build(constant: IndexSegment::Contracts::Update)
  step Contract::Validate()
  step Contract::Persist()
  pass :update_defaults
  step Transactions::Messages::SuccessMessage('View saved')

  def update_defaults(context, model:, current_user:, **)
    if model.reload.default
      IndexViewSegment.where(user: current_user, screen: model.screen).where.not(uuid: model.uuid).update_all(default: false)
    end
  end

end