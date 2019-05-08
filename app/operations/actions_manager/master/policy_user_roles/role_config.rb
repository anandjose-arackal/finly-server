class ActionsManager::Master::PolicyUserRoles::RoleConfig < ActionsManager::Master::Base

  register_handle :vp_role_config
  register_actions [:bank_payment_request_initiator, :purchase_request_initiator, :purchase_request_reviewer, :purchase_order_initiator,
    :purchase_order_reviewer, :goods_receiver, :invoice_initiator, :invoice_reviewer, :bank_payment_request_reviewer, 
    :bank_payment_request_creditor, :item_master_manager, :inventory_manager, :vendor_creator, :vendor_manager, 
    :vendor_reviewer, :policy_admin, :vendor_manager, :budget_manager, :non_po_initiator,
    :purchase_order_auditor, :bank_payment_request_auditor, :purchase_request_auditor, :invoice_auditor, :vendor_auditor
  ]

  def purchase_request_initiator
    user.company.purchase_requisition_enabled?
  end

  def purchase_request_reviewer
    user.company.purchase_requisition_enabled?
  end

  def purchase_order_initiator
    user.company.procurement_enabled?
    true
  end

  def purchase_order_reviewer
    user.company.procurement_enabled?
  end

  def goods_receiver
    user.company.procurement_enabled?
  end

  def invoice_initiator
    user.company.procurement_enabled?
  end

  def invoice_reviewer
    user.company.procurement_enabled?
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
    true
  end

  def vendor_creator
    user.company.vendor_empanelment_workflow_enabled?
  end

  def vendor_reviewer
    user.company.vendor_empanelment_workflow_enabled?
  end

  def policy_admin
    # true
  end

  def vendor_manager
    user.company.vendor_empanelment_workflow_enabled?
  end

  def bank_payment_request_auditor
  end

  def budget_manager
    user.company.budgeting_system_enabled?
  end

  def non_po_initiator
    user.company.procurement_enabled?
  end

  def purchase_order_auditor
    user.company.procurement_enabled?
  end

  def bank_payment_request_auditor
    true
  end
  
  def purchase_request_auditor
    user.company.purchase_requisition_enabled?
  end

  def invoice_auditor
    user.company.procurement_enabled?
  end

  def vendor_auditor
    user.company.vendor_empanelment_workflow_enabled?
  end
end