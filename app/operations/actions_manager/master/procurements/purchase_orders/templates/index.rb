class ActionsManager::Master::Procurements::PurchaseOrders::Templates::Index < ActionsManager::Master::Base

  register_handle :templates_index

  register_actions [:create_new_template]

  def create_new_template
    user.admin?
  end

end