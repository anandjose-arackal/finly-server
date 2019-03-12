class ActionsManager::Master::Procurements::PurchaseOrders::TaxInvoiceShow < ActionsManager::Master::Base

  register_handle :non_po_tax_invoice_show
  #Validate input if required
  register_actions [:more_details_button, :send_mail, :export_items, :submit, :reject, :approve, :remind, :retract, :remind_approver, :void, :save_btn, :export_po_items, :update_btn, :delete, :save_and_submit, :more_actions, :make_payment, :audit_trail, :download, :send_btn, :export_invoice_items]

  def initialize(user=nil, params={})
    super
    result = ::Procurements::Invoices::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.invoice = result.invoice
  end

  # alias_method :invoice, :input

  def more_details_button
    true
  end
  
  def send_mail
    (invoice.approved? || invoice.auto_approved?) &&
    (user_in_level?) || (document_owner?)
  end
  
  def export_items
    true
  end

  def submit
    document_owner? && (invoice.open? || invoice.retracted? || invoice.rejected?)
  end

  def reject
    invoice.processing? && user_in_level?
  end

  # def close
  #   true
  # end

  def approve
    invoice.processing? && user_in_level?
  end

  def remind
    invoice.processing? &&
    document_owner?
  end

  def retract
    invoice.processing? && document_owner?
  end

  def remind_approver
    invoice.processing? &&
    document_owner?
  end

  def void
    true
  end

  def save_btn
    user.vendor_payments_admin? || ( document_owner? && (invoice.open? || invoice.retracted? || invoice.rejected?) )
  end

  def export_po_items
    true
  end

  def update_btn
    if document_owner? && (invoice.open? || invoice.retracted? || invoice.rejected?)
      return true
    elsif invoice.processing? && user_in_level?
      return true
    end
  end

  def delete
    document_owner? && (invoice.open? || invoice.retracted? || invoice.rejected?)
  end

  def save_and_submit
    ( document_owner? && (invoice.open? || invoice.retracted? || invoice.rejected?) )
  end

  def more_actions
    true
  end

  def make_payment
    if (invoice.approved? || invoice.auto_approved? || invoice.unpaid? || invoice.partially_paid? || invoice.paid?)
      (user_in_level? && user.has_policy_role?(UserRole.id_for(:invoice_reviewer), invoice)) || user.has_policy_role?(UserRole.id_for(:invoice_reviewer), invoice)
    end
  end

  def audit_trail
    true
  end

  def download
    invoice.approved?
  end

  def send_btn
    # (invoice.approved? || invoice.auto_approved?) &&
    # (user_in_level?) || (document_owner?)
    true
  end

  def export_invoice_items
    true
  end

  def user_in_level?
    level = invoice.level
    amount = invoice.net_amount.value rescue 0
    level.present? ? level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id).include?(user.id) : false
  end

  def document_owner?
    invoice.created_by_user_id.eql? user.id
  end

end