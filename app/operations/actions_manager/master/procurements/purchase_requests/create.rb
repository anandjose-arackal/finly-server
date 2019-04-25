class ActionsManager::Master::Procurements::PurchaseRequests::Create < ActionsManager::Master::Base

  register_handle :purchase_request_create
  register_actions [:create_purchase_request, :delete_pr_line_item, :add_new_line_item]

  def create_purchase_request
    true
  end

  def delete_pr_line_item
    true
  end

  def add_new_line_item
    # If admin but not initiator, cannot save in draft stage
    if user.is_purchase_request_initiator?
      return true
    end
  end

end