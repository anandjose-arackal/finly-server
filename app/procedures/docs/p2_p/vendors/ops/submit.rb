# Vendor Submit will first create the vendor & Then submit it

class Docs::P2P::Vendors::Ops::Submit < Transactions::API


  step :init
  step :set_approval_matrix
  step :submit
  step :post_process

  def init(options, current_user:, params:, **)
    if params[:reviewal_document].present?
      options[:reviewal_document] = params[:reviewal_document]
    else
      op = Docs::P2P::Vendors::Ops::Show.(params: {id: params[:vendor_form_id]}, current_user: current_user)
      unless op.success?
        add_message options, :error, :base, op.messages[:errors]
        return
      end
      params[:reviewal_document] = op['model']
      options[:reviewal_document] = op['model']
    end
    true
  end

  def set_approval_matrix(options, current_user:, params:, **)
    if current_user.company.vendor_empanelment_workflow_enabled?
      # Create Document Level Reviewer Mapping
      # For setting level specific reviewers from reviewal chain for a document
      document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(current_user, params)
      unless document_reviewer_mappings_op.success?
        add_message options, :error, :base, document_reviewer_mappings_op.messages[:error]
        return
      end
      return true
    else
      add_message options, :success, :base, "Vendor Auto Approved"
      self.vendor.update(status_id: VendorStatus.id_for(:auto_approved))
    end
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

    reviewal_document.update(reject_note: nil) # clear reject note incase doc sent for reapproval
    true
  end

  def post_process(options, reviewal_document:, current_user:, **)
    if reviewal_document.status_id == VendorStatus.id_for(:auto_approved)
      add_message options, :success, :base, "Vendor Auto Approved"
    else
      add_message options, :success, :base, "Vendor Submitted for Approval"
    end
    Event::EVendors::Submit.(current_user, document: reviewal_document)
    true
  end
end