class ActionsManager::Master::Procurements::PurchaseOrders::Base < ActionsManager::Master::Base

  def input
    result = ::Procurements::PurchaseOrders::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    result.purchase_order
  end

end