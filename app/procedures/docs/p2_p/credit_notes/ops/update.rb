class Docs::P2P::CreditNotes::Ops::Update < Transactions::API


  step :set_default_params
  step Model(CreditNote, :find_by)
  step Policy::Pundit(Docs::P2P::CreditNotes::Authorizer, :update?)
  step Contract::Build(constant: Docs::P2P::CreditNotes::Contracts::Update)
  step Contract::Validate(key: 'credit_note')

  step Contract::Persist()
  step :setup_dlrm
  step :update_attachments

  step Transactions::Messages::SuccessMessage('Successfully Updated Credit Note')

  def set_default_params(options, params:, current_user:, **)
    params[:credit_note][:current_user] = current_user
  end

  def setup_dlrm(options, current_user:, params:, model:, **)

    dlrm_validation_op = ReviewalManager::DocumentReviewalMappings::Set.(current_user, {
        reviewal_document: model,
        document_reviewer_mappings: params[:document_reviewer_mappings]
    })

    dlrm_validation_op.success?
    true
  end

  def update_attachments(options, params:, current_user:, model:, **)
    attachment_ids = params[:credit_note][:attachments]

    cn_current_attachments = current_user.company.procurement_attachments.with_id(attachment_ids)

    cn_old_attachments = model.attachments

    cn_old_attachments.update_all(procurement_document_id: nil, procurement_document_type: nil)

    cn_current_attachments.update_all(procurement_document_id: model.id, procurement_document_type: model.class.name)
    true
  end
end