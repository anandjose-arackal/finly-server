# Updates Policy & Submits
class Docs::I2P::Invoices::Ops::Submit < Transactions::API

  step :init
  step :update_policy
  step :set_approval_matrix
  step :submit
  step :post_process


  def init(options, current_user:, params:, **)
    if params[:reviewal_document].present?
      options[:reviewal_document] = params[:reviewal_document]
    else
      op = Docs::I2P::Invoices::Ops::Show.(params: {id: params[:invoice_form_id]}, current_user: current_user)
      unless op.success?
        add_message options, :error, :base, op.messages[:errors]
        return
      end
      params[:reviewal_document] = op['model']
      options[:reviewal_document] = op['model']
    end
    true
  end

  def update_policy(options, reviewal_document:, current_user:, params:, **)
    reviewal_document.update(policy_id: params[:policy_id]) if params[:policy_id].present?
    true
  end

  def set_approval_matrix(options, current_user:, params:, **)
    # Create Document Level Reviewer Mapping
    # For setting level specific reviewers from reviewal chain for a document
    document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(current_user, params)
    unless document_reviewer_mappings_op.success?
      add_message options, :error, :base, document_reviewer_mappings_op.messages[:error]
      return
    end
    true
  end

  def submit(options, reviewal_document:, current_user:, **)

    workflow_params = {
        document: reviewal_document,
        aasm_event: 'submit'
    }

    op = WorkflowManager::Base.(current_user, workflow_params)
    unless op.success?
      add_message options, :error, :base, op.messages[:error]
      return
    end

    if reviewal_document.auto_approved?
      old_status_tag = StatusTag.find_by(id: StatusTag.id_for(:invoice_processing))
      status_tag = StatusTag.find_by(id: StatusTag.id_for(:invoice_approved))
      reviewal_document.procurement.status_tags.delete(old_status_tag)
      reviewal_document.procurement.status_tags << status_tag
    else
      status_tag = StatusTag.find_by(id: StatusTag.id_for(:invoice_processing))
      unless reviewal_document.procurement.status_tags.include? status_tag
        reviewal_document.procurement.status_tags << status_tag
      end
    end

    reviewal_document.update(rejection_note: "")
    options[:workflow_output] = op.workflow_output
    true
  end

  def post_process(options, reviewal_document:, current_user:, **)
    # Methods from Procurements::Invoices::Submit
    # budget_limit_validation( invoice )
    # update_agreement_available_limit
    role_id = options[:workflow_output][:role_id]
    Event::EInvoice::Submit.(current_user, {invoice: reviewal_document,
                                            workflow_output: options[:workflow_output], role_id: role_id})

    # Email to vendor that invoice is generated when the invoice is approved/auto_approved
    # Event::EInvoice::VendorMail.(user, invoice: invoice, workflow_output: workflow_output) if self.invoice.approved? || self.invoice.auto_approved?
    add_message options, :success, :base, 'Successfully submitted invoice'

    true
  end
end