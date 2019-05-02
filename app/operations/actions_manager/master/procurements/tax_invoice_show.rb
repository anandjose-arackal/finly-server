class ActionsManager::Master::Procurements::TaxInvoiceShow < ActionsManager::Master::Base

  register_handle :proc_tax_invoice_show
  validate :input

  # register_actions [:more_details_button, :send_mail, :export_items, :submit, :reject, :approve, :remind, :retract, :remind_approver, :save_btn, :save_and_submit, :delete, :more_actions, :make_payment, :audit_trail, :download, :send_btn, :export_po_items, :update_btn, :unapprove]

  register_actions [:more_details_button, :export_items, :submit, :reject, :approve, :remind, :retract, :remind_approver, :save_btn, :save_and_submit, :delete, :more_actions, :audit_trail, :download, :send_btn, :export_po_items, :update_btn, :unapprove, :take_control, :return_control, :forward]


  def initialize(user = nil, params = {})
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

  def export_items
    #No Conditions
    true
  end

  def submit
    if invoice.is_initiating_user?
      document_owner? && (invoice.open? || invoice.retracted? || invoice.rejected?)
    end
  end

  def reject
    if invoice.is_reviewing_user? || admin_has_taken_control?
      invoice.processing? && user_in_level?
    end
  end

  def close
    true
  end

  def approve
    if invoice.is_reviewing_user? || admin_has_taken_control?
      invoice.processing? && user_in_level?
    end
  end

  def unapprove
    unless invoice.approved?
      if last_level?
        state = (previous_reviewer.include? user.id) ? true : false
      else
        previous_reviewer.include? user.id
      end
    end
  end


  # def take_control
  #   if user.vendor_payment_admin? && purchase_order.processing? && user_can_take_control?
  #     true
  #   end
  # end

  # def return_control
  #   if user.vendor_payment_admin? && purchase_order.processing? && user_can_return_control?
  #     true
  #   end
  # end

  def take_control
    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      if (invoice.processing? && invoice.get_reviewers.exclude?(user))
        return true
      end
      if invoice.processing? && !invoice.action_users(:return_control).include?(user) && !invoice.action_users(:approve).include?(user)
        return true
      end
    end
    ############# Admin logic end ####################    
  end

  def return_control
    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      if invoice.processing?
        return true if invoice.action_users(:return_control).include?(user)
      end
    end
    ############# Admin logic end ####################
  end



  def remind
    invoice.is_initiating_user? and invoice.processing? and document_owner?
  end

  def retract
    invoice.is_initiating_user? and invoice.processing? and document_owner?
  end

  def remind_approver
    invoice.processing? && document_owner?
  end

  def save_btn
    # (user.vendor_payments_admin?) || ( document_owner? && (invoice.open? || invoice.retracted? || invoice.rejected?) ) ||
    # (invoice.processing? && user_in_level?)
    (document_owner? && (invoice.open? || invoice.retracted? || invoice.rejected?)) || user.vendor_payments_admin?
  end

  def save_and_submit
    # ( document_owner? && (invoice.open? || invoice.retracted? || invoice.rejected?) ) ||
    # (invoice.processing? && user_in_level?) ||
    # (user.vendor_payments_admin?)
    (document_owner? && (invoice.open? || invoice.retracted? || invoice.rejected?))
  end

  def delete
    document_owner? && (invoice.open? || invoice.retracted? || invoice.rejected?)
  end

  def more_actions
    true
  end

  def audit_trail
    #No Conditions
    true
  end

  def download
    invoice.approved?
  end

  def send_btn
    true
  end

  def export_po_items
    true
  end

  def update_btn
    (document_owner? && (invoice.open? || invoice.retracted? || invoice.rejected?)) ||
        (invoice.processing? && user_in_level?)
  end

  def last_level?
    if invoice.processing?
      invoice.get_reviewal_chain&.last[:level_number] == invoice.level&.level_number
    end
  end

  def previous_reviewer
    invoice.get_reviewers('previous').pluck(:id)
  end

  def user_can_take_control?
    # check for the current level if it isn't taken control
    # check if the same user is not taking control twice
    # check if for the same level if any other user has also taken control
    (purchase_order.dlrms&.find_by(level_id: purchase_order.level&.id).taken_control_by_id != user.id)
  end

  def user_can_return_control?
    invoice.dlrms&.find_by(level_id: invoice.level&.id).taken_control &&
    invoice.dlrms&.find_by(level_id: invoice.level&.id).taken_control_by_id == user.id
  end

  def user_in_level?
    # level = invoice.level
    # amount = invoice.net_amount.value rescue 0
    # allowed = level.present? ? level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id).include?(user.id) : false
    invoice.get_reviewers.include?(user)
  end

  def document_owner?
    invoice.created_by_user_id.eql? user.id
  end

  def forward
    invoice.processing? && invoice.get_reviewers.include?(user)
  end

  def admin_has_taken_control?
    # If the user is an admin and the admin has explicitly taken control of the document, 
    # only then they can approve or reject
    purchase_order.get_reviewers.include?(user) && user.vendor_payment_admin?
  end
end