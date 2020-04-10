class Docs::UtilityBills::Subscriptions::Ops::Update < Transactions::API

  step :set_default_params

  step Model(BbpsBillerSubscription, :find_by)

  step Policy::Pundit( Docs::UtilityBills::Subscriptions::Authorizer, :update? )

  step Contract::Build(constant: Docs::UtilityBills::Subscriptions::Contracts::Update)

  step Contract::Validate(key: 'subscription')

  step Contract::Persist()

  step :setup_dlrm

  step :assign_poc_roles

  step :update_attachments

  step Transactions::Messages::SuccessMessage('Successfully Updated Utility Bill Master')

  def set_default_params(options, params:, current_user:, **)
    params[:subscription][:current_user] = current_user
  end

  def assign_poc_roles(options, model:, params:, **)
    model.pocs.each do |poc|
      pur = PolicyUserRole.find_or_initialize_by(user_id: poc.id, policy_id: model.policy_id, user_role_id: UserRole.id_for(:utility_bill_initiator))
      pur.save
    end
    true
  end

  def update_attachments(options, params:, current_user:, model:, **)
    attachments = Attachment.where(id: params[:attachment_ids])
    attachment_ids = attachments.where(resource_id: nil).or(attachments.where(resource_id: model.id, resource_type: model.class.name)).pluck(:id)

    Attachment.where(id: attachment_ids).update(resource_id: model.id, resource_type: model.class.name)
    model.attachments.where.not(id: attachment_ids).destroy_all
    true
  end

  def setup_dlrm(options, current_user:, params:, model:, **)
    dlrm_validation_op = ReviewalManager::DocumentReviewalMappings::Set.(current_user, {
        reviewal_document: model,
        document_reviewer_mappings: params[:document_reviewer_mappings]
    })

    dlrm_validation_op.success?
  end
end