class ActionsManager::Master::Procurements::PurchaseOrders::Base < ActionsManager::Master::Base

  def initialize(user=nil, params={})
    super
    result = ::Procurements::PurchaseOrders::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.purchase_order = result.purchase_order
  end

end