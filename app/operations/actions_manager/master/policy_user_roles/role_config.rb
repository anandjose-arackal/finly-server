class ActionsManager::Master::PolicyUserRoles::RoleConfig < ActionsManager::Master::Base

  register_handle :vp_role_config
  register_actions [:bank_payment_request_initiator, :purchase_request_initiator, :purchase_request_reviewer, :purchase_order_initiator, :purchase_order_reviewer, :goods_receiver, :invoice_initiator, :invoice_reviewer, :bank_payment_request_reviewer, :bank_payment_request_creditor, :item_master_manager, :inventory_manager, :vendor_creator, :vendor_manager, :vendor_reviewer, :policy_admin, :vendor_manager, :budget_manager, :non_po_initiator]

  def purchase_request_initiator
    # true
  end

  def purchase_request_reviewer
    # true
  end

  def purchase_order_initiator
    true
  end

  def purchase_order_reviewer
    true
  end

  def goods_receiver
    true
  end

  def invoice_initiator
    true
  end

  def invoice_reviewer
    true
  end

  def bank_payment_request_initiator
    true
  end

  def bank_payment_request_reviewer
    true
  end

  def bank_payment_request_creditor
    true
  end

  def item_master_manager
    true
  end

  def inventory_manager
    # true
  end

  def vendor_creator
    true
  end

  def vendor_reviewer
    true
  end

  def policy_admin
    # true
  end

  def vendor_manager
    true
  end

  def bank_payment_request_auditor
  end

  def budget_manager
    true
  end

  def non_po_initiator
    true
  end
end