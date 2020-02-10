class ActionsManager::Master::Procurements::PurchaseRequests::Index < ActionsManager::Master::Base

  register_handle :purchase_request_index
  register_actions [
                      :create_purchase_request,
                      :export_all,
                      :bulk_delete,
                      :bulk_approve,
                      :bulk_reject,
                      :bulk_control,
                      :export_as_xls,
                      :export_as_csv,
                      :bulk_actions
                    ]

  def create_purchase_request
    user.vendor_payment_admin? || user.is_purchase_request_initiator?
  end

  def export_all
    true
  end

  def bulk_delete
    user.vendor_payment_admin?
  end

  def bulk_approve
    user.vendor_payment_admin? || user.is_purchase_request_reviewer?
  end

  def bulk_reject
    user.vendor_payment_admin? || user.is_purchase_request_reviewer?
  end

  def bulk_control
    user.vendor_payment_admin?
  end

  def export_as_xls
    true
  end

  def export_as_csv
    true
  end

  def bulk_actions
    true
  end


end