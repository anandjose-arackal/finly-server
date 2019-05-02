class Procurements::Invoices::Unapprove < Procurements::Invoices::Base
  attr_accessor :invoice, :procurement

  def init
    invoice_id = params[:id] || params[:invoice_id] || params[:inward_invoice_id]
    # todo scope it and in all similar places
    self.invoice = user.company.inward_invoices.find_by id: invoice_id

    self.procurement = self.invoice&.procurement
  end

  def validate
    unless self.invoice.present?
      add_message :error, 'Invoice not found'
      return
    end

    unless invoice.level.present?
      add_message :error, 'Cannot take action against Invoice at this state'
      return
    end

    unless unapprovable?
      add_message :error, 'You cannot unapprove this Invoice at this state'
    end
  end

  def process
    params[:document] = self.invoice
    params[:aasm_event] = 'unapprove'
    params[:violation_present] = false #todo Check violations
    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end
    # if invoice.processing?
    #   old_status_tag = StatusTag.find_by(id: StatusTag.id_for(:po_processing))
    #   status_tag = StatusTag.find_by(id: StatusTag.id_for(:po_approved))
    #   self.procurement.status_tags.delete(old_status_tag)
    #   self.procurement.status_tags << status_tag
    # end

    self.workflow_output = op.workflow_output
  end

  def post_process
    # role_id = self.workflow_output[:role_id]
    # Event::EInvoice::Unapprove.(user, invoice: invoice, workflow_output: self.workflow_output)
    add_message :success, 'Successfully Unapproved Invoice'
  end

  def unapprovable?
    # after approval(in previous action by the user)
    # if it has been retracted / approved unapprove action can't be taken
    last_approve_trail = self.invoice.trails.only_approve.last
    last_retract_trail = self.invoice.trails.only_retract.last
    if last_approve_trail.action_user.id == user.id
      if last_retract_trail.present? && last_retract_trail.created_at > last_approve_trail.created_at
        return false
      end
      return true
    else
      return false
    end
  end
end








