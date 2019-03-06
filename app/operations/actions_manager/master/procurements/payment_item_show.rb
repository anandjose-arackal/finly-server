class ActionsManager::Master::Procurements::PaymentItemShow < ActionsManager::Master::Base

  register_handle :proc_payment_item_show
  register_actions [:view_payment_item]

  def view_payment_item
    true
  end
end