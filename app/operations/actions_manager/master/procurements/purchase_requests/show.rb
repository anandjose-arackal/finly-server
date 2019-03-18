class ActionsManager::Master::Procurements::PurchaseRequests::Show < ActionsManager::Master::Base

  register_handle :purchase_request_show
  register_actions [ :submit, :retract, :reject, :approve, :take_control ]


end