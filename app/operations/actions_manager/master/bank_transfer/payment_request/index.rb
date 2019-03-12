class ActionsManager::Master::BankTransfer::PaymentRequest::Index < ActionsManager::Master::Base

  register_handle :payment_ticket_index
  register_actions [ :new_orders, :bulk_actions,:export_sap, :mark_as_credited, :credit_payment_order, :approve_selected, :approve_pending, :upload_utr, :bulk_downloads, :download_payment_files, :download_pending, :download_selected, :download_all, :export, :tally, :quickbooks, :sap, :oracle_ns, :take_control]


  def new_orders
    # user.vendor_payments_admin? || user.vendor_payments_creditor? || user.vendor_payment_reviewer? || user.vendor_payments_initiator?
    user.has_policy_role?(UserRole.id_for(:admin)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_reviewer)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_initiator))
  end

  def bulk_actions
    # user.vendor_payments_admin? || user.vendor_payments_creditor? || user.vendor_payment_reviewer?
    user.has_policy_role?(UserRole.id_for(:admin)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_reviewer))
  end

  def export_sap
    true
  end

  def mark_as_credited
    true
  end

  def credit_payment_order
    true
  end

  def approve_selected
    true
  end

  def approve_pending
    true
  end

  def upload_utr
    true
  end

  def bulk_downloads
    user.has_policy_role?(UserRole.id_for(:admin)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_reviewer)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_auditor)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_initiator))
  end

  def download_payment_files
    # user.vendor_payments_admin? || user.vendor_payments_creditor? || user.vendor_payment_reviewer? || user.vendor_payments_auditor? || user.vendor_payments_initiator?
    user.has_policy_role?(UserRole.id_for(:admin)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_reviewer)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_auditor)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_initiator))
  end

  def download_pending
    # user.vendor_payments_admin? || user.vendor_payments_creditor? || user.vendor_payment_reviewer? || user.vendor_payments_auditor? || user.vendor_payments_initiator?
    user.has_policy_role?(UserRole.id_for(:admin)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_reviewer)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_auditor)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_initiator))
  end

  def download_selected
    true
  end

  def download_all
    true
  end

  def export
    true
  end

  def tally
    true
  end

  def quickbooks
    true
  end

  def sap
    true
  end

  def oracle_ns
    true
  end

  def take_control
    # user.vendor_payments_admin?
    user.has_policy_role?(UserRole.id_for(:admin))
  end


end