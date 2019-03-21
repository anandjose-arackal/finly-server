class ActionsManager::Master::Procurements::PurchaseRequests::Index < ActionsManager::Master::Base

  register_handle :purchase_request_index
  register_actions [:create_purchase_request]

  def create_purchase_request
    true
  end
end