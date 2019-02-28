class ActionsManager::Master::Procurements::PurchaseOrders::InwardDocumentShow < ActionsManager::Master::Procurements::PurchaseOrders::Base

  register_handle :non_po_inward_document_show
  register_actions [:update_document]

  def update_document
    true
  end
  # alias_method :purchase_order, :input
  
  # def more_details_button
  #   true
  # end
  
  # def send_mail
  #   true
  # end
  
  # def export_items
  #   true
  # end

  # def submit
  #   document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?)
  # end

  # def reject
  #   purchase_order.processing? && user_in_level?
  # end

  # def close
  #   true
  # end

  # def approve
  #   purchase_order.processing? && user_in_level?
  # end

  # def remind
  #   true
  # end

  # def retract
  #   purchase_order.processing? && document_owner?
  # end

  # def remind_approver
  #   true
  # end

  # def void
  #   true
  # end

  # def save_btn
  #   document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?)
  # end

  # def export_po_items
  #   true
  # end

  # def update_btn
  #   (document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?)) || 
  #   (purchase_order.processing? && user_in_level?)
  # end

  # def delete
  #   document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?)
  # end

  # def save_and_submit
  #   document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?)
  # end

  # def more_actions
  #   true
  # end

  # def make_payment
  #   if purchase_order.approved? || purchase_order.auto_approved? || purchase_order.unpaid? || purchase_order.partially_paid? || purchase_order.paid?
  #     (user_in_level? && user.vendor_payment_creditor?) || user.vendor_payment_creditor?
  #   end
  # end

  # def audit_trail
  #   true
  # end

  # def download
  #   true
  # end

  # def send_btn
  #   true
  # end

  # def export_invoice_items
  #   true
  # end

  # def user_in_level?
  #   level = purchase_order.level
  #   amount = purchase_order.net_amount.value rescue 0
  #   level.present? ? level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id).include?(user.id) : false
  # end

  # def document_owner?
  #   purchase_order.created_by_user_id.eql? user.id
  # end

end