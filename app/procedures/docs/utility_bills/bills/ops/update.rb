class Docs::UtilityBills::Bills::Ops::Update < Trailblazer::Operation
  step Model(BbpsBill, :find_by)
  step Policy::Pundit(Docs::UtilityBills::Bills::Authorizer, :update?)
  # step :set_default_params
  step Contract::Build(constant: Docs::UtilityBills::Bills::Contracts::Update)
  step Contract::Validate(key: 'bill')
  step Contract::Persist()

  step :setup_dlrm
  failure :check

  def check(options, params:, **)
  end

  def setup_dlrm(options, current_user:, params:, model:, **)
    dlrm_validation_op = ReviewalManager::DocumentReviewalMappings::Set.(current_user, {
        reviewal_document: model,
        document_reviewer_mappings: params[:document_reviewer_mappings]
    })
    dlrm_validation_op.success?
  end

  def set_default_params(options, params:, current_user:, **)
    # Set Initiator
    params[:subscription][:user_id] = current_user&.id
  end
end