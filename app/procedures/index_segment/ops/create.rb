class IndexSegment::Ops::Create < Transactions::API

  step Model(IndexViewSegment, :new)
  step Policy::Pundit(IndexSegment::Policy, :create?)
  step AssignModelUser()
  step Contract::Build(constant: IndexSegment::Contracts::Create)
  step Contract::Validate()
  step Contract::Persist()
  pass :update_defaults
  step Transactions::Messages::SuccessMessage('View saved')

  def update_defaults(context, model:, current_user:, **)
    if model.default
      IndexViewSegment.where(user: current_user, screen: models.screen).where.not(id: model.id).update_all(default: false)
    end
  end

end