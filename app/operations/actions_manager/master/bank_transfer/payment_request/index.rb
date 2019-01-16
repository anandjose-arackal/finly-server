class ActionsManager::Master::BankTransfer::PaymentRequest::Index < ActionsManager::Master::Base

  register_handle :payment_request_index
  # validate :input
  register_actions [ :new_orders, :bulk_actions,:export_sap, :mark_as_credited, :credit_payment_order, :approve_selected, :approve_pending, :upload_utr, :bulk_downloads, :download_payment_files, :download_pending, :download_selected, :download_all, :export, :tally, :quickbooks, :sap, :oracle_ns]


  def new_orders
    user.admin?
  end

  def bulk_actions
    user.admin?
  end

  def export_sap
    user.admin?
  end

  def mark_as_credited
    user.admin?
  end

  def credit_payment_order
    user.admin?
  end

  def approve_selected
    user.admin?
  end

  def approve_pending
    user.admin?
  end

  def upload_utr
    user.admin?
  end

  def bulk_downloads
    user.admin?
  end

  def download_payment_files
    user.admin?
  end

  def download_pending
    user.admin?
  end

  def download_selected
    user.admin?
  end

  def download_all
    user.admin?
  end

  def export
    user.admin?
  end

  def tally
    user.admin?
  end

  def quickbooks
    user.admin?
  end

  def sap
    user.admin?
  end

  def oracle_ns
    user.admin?
  end


end