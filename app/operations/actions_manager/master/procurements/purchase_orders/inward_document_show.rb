class ActionsManager::Master::Procurements::PurchaseOrders::InwardDocumentShow < ActionsManager::Master::Procurements::PurchaseOrders::Base

  register_handle :non_po_inward_document_show
  register_actions [:more_details_button, :send_mail, :export_items, :submit, :reject, :close, :approve, :remind, :retract, :remind_approver, :void, :save_btn, :export_po_items, :update_btn, :delete, :save_and_submit, :more_actions, :make_payment, :audit_trail, :download, :send_btn, :export_invoice_items]
  # alias_method :purchase_order, :input
  
  def more_details_button
    true
  end
  
  def send_mail
    true
  end
  
  def export_items
    true
  end

  def submit
    true
  end

  def reject
    true
  end

  def close
    true
  end

  def approve
    true
  end

  def remind
    true
  end

  def retract
    true
  end

  def remind_approver
    true
  end

  def void
    true
  end

  def save_btn
    true
  end

  def export_po_items
    true
  end

  def update_btn
    true
  end

  def delete
    true
  end

  def save_and_submit
    true
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
    true
  end

  def send_btn
    true
  end

  def export_invoice_items
    true
  end

end