class ActionsManager::Master::Bbps::Subscriptions::Index < ActionsManager::Master::Base

  register_handle :bbps_subscriptions_index
  register_actions [:create]

  def create
    user.has_policy_role?(UserRole.id_for(:utility_bill_master_initiator))
  end
end