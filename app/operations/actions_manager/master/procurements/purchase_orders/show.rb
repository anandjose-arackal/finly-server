class ActionsManager::Master::Procurements::PurchaseOrders::Show < ActionsManager::Master::Base

  register_handle :non_po_show


  register_actions [:add_document]

  def add_document
    user.vendor_payments_admin?
  end

end