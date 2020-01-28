class ActionsManager::Master::Procurements::PurchaseOrders::TaxInvoiceShow < ActionsManager::Master::Base

  register_handle :non_po_tax_invoice_show
  #Validate input if required
  register_actions [:more_details_button, :send_mail, :export_items, :submit, :reject, :approve, :remind,
                    :retract, :remind_approver, :void, :save_btn, :export_po_items, :update_btn, :delete,
                    :save_and_submit, :more_actions, :make_payment, :audit_trail, :download, :send_btn,
                    :export_invoice_items, :take_control, :return_control, :forward, :disable_agreement_related_fields,
                    :create_credit_note, :create_items]

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
    false
  end
  
  def export_items
    true
  end

  def submit
    if user.is_non_po_invoice_initiator?
      document_owner? && (invoice.open? || invoice.retracted? || invoice.rejected?)
    end
  end

  def reject
    if invoice.is_non_po_reviewing_user? || user.vendor_payment_admin?
      invoice.processing? && user_in_level?
    end
  end

  # def close
  #   true
  # end

  def approve
    if invoice.is_non_po_reviewing_user? || user.vendor_payment_admin?
      invoice.processing? && user_in_level?
    end
  end

  def forward
    if invoice.is_non_po_reviewing_user?
      invoice.processing? && user_in_level?
    end
  end

  def take_control
    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      if (invoice.processing? && invoice.get_reviewers(nil, provider_name).exclude?(user))
        return true
      end
      if invoice.processing? && !invoice.action_users(:return_control, provider_name).include?(user) && !invoice.action_users(:approve, provider_name).include?(user)
        return true
      end
    end
    ############# Admin logic end ####################    
  end

  def return_control
    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      if invoice.processing?
        return true if invoice.action_users(:return_control, provider_name).include?(user)
      end
    end
    ############# Admin logic end ####################
  end

  def remind
    invoice.processing? &&
    document_owner?
  end

  def retract
    if user.is_non_po_invoice_initiator?
      invoice.processing? && document_owner?
    end
  end

  def remind_approver
    if invoice.is_po_initiating_user?
      invoice.processing? &&
      document_owner?
    end
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
    if user.is_non_po_invoice_initiator?
      document_owner? && (invoice.open? || invoice.retracted? || invoice.rejected?)
    end
  end

  def save_and_submit
    if user.is_non_po_invoice_initiator?
      ( document_owner? && (invoice.open? || invoice.retracted? || invoice.rejected?) )
    end
  end

  def more_actions
    true
  end

  def make_payment
    # if (invoice.approved? || invoice.auto_approved? || invoice.unpaid? || invoice.partially_paid? || invoice.paid?)
    #   (user_in_level? && user.has_policy_role?(UserRole.id_for(:invoice_reviewer), invoice)) || user.has_policy_role?(UserRole.id_for(:invoice_reviewer), invoice)
    # end
    (invoice.approved? || invoice.auto_approved? || invoice.unpaid? || invoice.partially_paid?) && user.is_bank_payment_request_initiator?(invoice)
  end

  def audit_trail
    true
  end

  def download
    false
  end

  def send_btn
    # (invoice.approved? || invoice.auto_approved?) &&
    # (user_in_level?) || (document_owner?)
    false
  end

  def export_invoice_items
    true
  end

  def disable_agreement_related_fields
    created_from_payment_agreement
  end

  def created_from_payment_agreement
    invoice.payment_agreement_id.present?
  end

  def user_in_level?
    # level = invoice.level
    # amount = invoice.net_amount.value rescue 0
    # level.present? ? level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id).include?(user.id) : false
    invoice.get_reviewers(nil, provider_name).include?(user)
  end

  def document_owner?
    invoice.created_by_user_id.eql? user.id
  end

  def provider_name
    invoice.get_invoice_provider_name
  end

  def create_credit_note
    InwardInvoiceStatus.ids_for(:paid).include?(invoice.invoice_status_id) && user.has_policy_role?(UserRole.id_for(:credit_note_initiator)) && invoice.credit_note.blank?
  end

  def create_items
    user.permission.crud_inventory_item_non_po
  end

end