class ActionsManager::Master::Procurements::PurchaseOrders::Show < ActionsManager::Master::Procurements::PurchaseOrders::Base

  register_handle :non_po_show
  register_actions [:add_document]
  # alias_method :purchase_order, :input
  
  def add_document
    true
  end

end