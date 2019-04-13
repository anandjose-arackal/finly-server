class ActionsManager::Master::Procurements::PurchaseRequests::Create < ActionsManager::Master::Base

  register_handle :purchase_request_create
  register_actions [:create_purchase_request, :delete_pr_line_item]

  def create_purchase_request
    true
  end

  def delete_pr_line_item
    true
  end

end