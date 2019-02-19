class ActionsManager::Master::Procurements::PurchaseOrderShow < ActionsManager::Master::Base

  register_handle :proc_purchase_order_show
  validate :input
  register_actions [:more_details_button, :send_mail, :export_items, :submit, :reject, :approve, :remind, :retract, :remind_approver, :void, :save_btn, :save_and_submit, :delete, :more_actions, :make_payment, :audit_trail, :download, :send_btn, :export_po_items, :update_btn]

  def initialize(user=nil, params={})
    super
    result = ::Procurements::PurchaseOrders::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.purchase_order = result.purchase_order
  end

  def more_details_button
    true
  end

  def send_mail
    (purchase_order.approved? || purchase_order.auto_approved?) &&
    (user_in_level?) || (document_owner?)

  end

  def export_items
    true
  end

  def submit
    document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?)
  end
  
  def reject
    purchase_order.processing? &&
    user_in_level?
  end

  def close
    true
  end

  def approve
    purchase_order.processing? &&
    user_in_level?
  end

  def remind
    purchase_order.processing? &&
    document_owner?
  end

  def retract
    purchase_order.processing? &&
    document_owner?
  end

  def remind_approver
    purchase_order.processing? &&
    document_owner?
  end

  def void
    PurchaseOrderStatus.status_ids_for_voidable.include?(purchase_order.purchase_order_status_id) &&
    user.vendor_payment_admin?
  end

  def save_btn
    # ( document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?) ) ||
    # (purchase_order.processing? && user_in_level?) ||
    # (user.vendor_payment_admin? && purchase_order.voided?)
    ( document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?) ) || user.vendor_payment_admin?
  end

  def save_and_submit
    # ( document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?) ) ||
    # (purchase_order.processing? && user_in_level?) ||
    # (user.vendor_payment_admin? && purchase_order.voided?)
    ( document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?) )
  end

  def delete
    document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?)
  end

  def more_actions
    true
  end

  def make_payment
    (purchase_order.approved? || purchase_order.auto_approved?) && (user_in_level?)
  end

  def audit_trail
    true
  end

  def download
    (purchase_order.approved? || purchase_order.auto_approved?)
  end

  def send_btn
    if (purchase_order.approved? || purchase_order.auto_approved?)
      (user_in_level? || document_owner?)
    end
  end

  def export_po_items
    true
  end

  def update_btn
    true
  end

  def document_owner?
    purchase_order.user_id.eql?(user.id)
  end

  def user_in_level?
    level = purchase_order.level
    amount = purchase_order.balance_amount.value rescue 0
    level.present? ? level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id).include?(user.id) : false
  end

end