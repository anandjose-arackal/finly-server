class Docs::UtilityBills::Subscriptions::Ops::AddBill < Transactions::API

  step Model(BbpsBillerSubscription, :new)
  step Policy::Pundit(Docs::UtilityBills::Subscriptions::Authorizer, :create?)
  step :set_default_params
  step Contract::Build(constant: Docs::UtilityBills::Subscriptions::Contracts::Base)
  step Contract::Validate(key: 'subscription')

  failure :check
  step Contract::Persist()
  step :setup_dlrm


  def check(params, **)
  end

  def setup_dlrm(options, current_user:, params:, model:, **)
    dlrm_validation_op = ReviewalManager::DocumentReviewalMappings::Set.(current_user, {
        reviewal_document: model,
        document_reviewer_mappings: params[:document_reviewer_mappings]
    })
    dlrm_validation_op.success?
  end

  def set_default_params(options, params:, current_user:, **)
    params[:subscription][:user_id] = current_user&.id
    params[:subscription][:current_user] = current_user
  end
end