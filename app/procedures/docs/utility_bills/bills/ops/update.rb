class Docs::UtilityBills::Bills::Ops::Update < Transactions::API
  step Model(BbpsBill, :find_by)
  step Policy::Pundit(Docs::UtilityBills::Bills::Authorizer, :update?)
  # step :set_default_params
  step Contract::Build(constant: Docs::UtilityBills::Bills::Contracts::Update)
  step Contract::Validate(key: 'bill')
  step Contract::Persist()

  step :setup_dlrm
  step :update_attachments

  fail :check
  step Transactions::Messages::SuccessMessage('Successfully Updated Utility Bill')

  def check(options, params:, **)
  end

  def setup_dlrm(options, current_user:, params:, model:, **)
    if BbpsBill.open_statuses.include?(model.status_id) && model.subscription.pocs.include?(current_user)
      dlrm_validation_op = ReviewalManager::DocumentReviewalMappings::Set.(current_user, {
          reviewal_document: model,
          document_reviewer_mappings: params[:document_reviewer_mappings]
      })

      dlrm_validation_op.messages.slice(:error, :success, :info).each do |key, val|
        next if key == :errors_meta
        add_message options, key, :base, val
      end

      dlrm_validation_op.success?
    else
      true
    end
  end

  def update_attachments(options, params:, current_user:, model:, **)
    attachment_ids = params[:attachment_ids]
    attachments_to_remove = model.attachments.where.not(id: attachment_ids)
    attachments_to_remove.destroy_all
    true
  end
end