class ActionsManager::Master::Bbps::Bills::Index < ActionsManager::Master::Base

  register_handle :bbps_bills_index
  register_actions [:create]

  def create
    user.has_policy_role?(UserRole.id_for(:utility_bill_initiator))
  end

end