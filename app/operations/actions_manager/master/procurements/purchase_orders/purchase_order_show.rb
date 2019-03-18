class ActionsManager::Master::Procurements::PurchaseOrders::PurchaseOrderShow < ActionsManager::Master::Procurements::PurchaseOrders::Base

  register_handle :non_po_purchase_order_show
  validate :input
  register_actions [:more_details_button, :send_mail, :export_items, :submit, :reject, :close, :approve, :remind, :retract, :remind_approver, :void, :save_btn, :export_po_items, :update_btn, :delete, :save_and_submit, :more_actions, :make_payment, :audit_trail, :download, :send_btn, :export_invoice_items]

  def more_details_button
    true
  end
  
  def send_mail
    if purchase_order.is_initiating_user?
      (purchase_order.approved? || purchase_order.auto_approved?) && 
      (user_in_level? || document_owner?)
    end
  end
  
  def export_items
    true
  end

  def submit
    if purchase_order.is_initiating_user?
      document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?)
    end
  end

  def reject
    if purchase_order.is_initiating_user?
      purchase_order.processing? &&
      user_in_level?
    end
  end

  def close
    true
  end

  def approve
    if purchase_order.is_reviewing_user?
      purchase_order.processing? &&
      user_in_level?
    end
  end

  def remind
    purchase_order.processing? &&
    document_owner?
  end

  def retract
    if purchase_order.is_initiating_user?
      purchase_order.processing? &&
      document_owner?
    end
  end

  def remind_approver
    if purchase_order.is_initiating_user?
      purchase_order.processing? &&
      document_owner?
    end
  end

  def void
    (PurchaseOrderStatus.status_ids_for_voidable.include? purchase_order.purchase_order_status_id) && 
      user.vendor_payments_admin?
  end

  def save_btn
    (user.vendor_payments_admin? && !purchase_order.voided?) || (document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?)) || 
    (purchase_order.processing? && user_in_level?)
    # (document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?))
  end

  def export_po_items
    true
  end

  def update_btn
    true
  end

  def delete
    if purchase_order.is_initiating_user?
      document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?)
    end
  end

  def save_and_submit
    if purchase_order.is_initiating_user?
      (document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?))
    end
  end

  def more_actions
    true
  end

  def make_payment
    true
  end

  def audit_trail
    true
  end

  def download
    purchase_order.approved? || purchase_order.auto_approved?
  end

  def send_btn
    true
  end

  def export_invoice_items
    true
  end

  def document_owner?
    purchase_order.user_id.eql?(user.id)
  end

  def user_in_level?
    level = purchase_order.level
    amount = purchase_order.balance_amount.value rescue 0
    level.present? ? level.level_reviewer_mappings.non_deleted.with_threshold(amount).pluck(:reviewer_id).include?(user.id) : false
  end

end