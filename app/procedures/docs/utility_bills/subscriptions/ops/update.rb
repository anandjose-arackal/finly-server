class Docs::UtilityBills::Subscriptions::Ops::Update < Transactions::API

  step :set_default_params

  step Model(BbpsBillerSubscription, :find_by)

  step Policy::Pundit( Docs::UtilityBills::Subscriptions::Authorizer, :update? )

  step Contract::Build(constant: Docs::UtilityBills::Subscriptions::Contracts::Update)

  step Contract::Validate(key: 'subscription')

  step Contract::Persist()

  step :update_attachments

  step Transactions::Messages::SuccessMessage('Successfully Updated Utility Bill Master')

  def set_default_params(options, params:, current_user:, **)
    params[:subscription][:current_user] = current_user
  end

  def update_attachments(options, params:, current_user:, model:, **)
    attachments = Attachment.where(id: params[:attachment_ids])
    attachment_ids = attachments.where(resource_type: nil, resource_id: nil).or(attachments.where(resource: model)).pluck(:id)

    Attachment.where(id: attachment_ids).update(resource_id: model, resource_type: model.class.name)
    model.attachments.where.not(id: attachment_ids).destroy_all
    true
  end
end