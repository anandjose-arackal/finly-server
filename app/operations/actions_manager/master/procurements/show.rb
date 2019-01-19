class ActionsManager::Master::Procurements::Show < ActionsManager::Master::Base

  register_handle :procurements_show

  register_actions [:add_document]

  def add_document
    user.vendor_payments_admin?
  end

end