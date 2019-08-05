class ReminderAwaitingApproval < ApplicationJob

  def perform
    # Loop through Reviewers and find the awaiting approval items
    remind_purchase_request_reviewer
    remind_invoice_reviewer
    remind_bank_payment_request_reviewer
    remind_purchase_order_reviewer
  end

  private

  def remind_purchase_request_reviewer
    pr_reviewer_ids = Policy.where(company_id: 156).joins(:policy_user_roles).where('policy_user_roles.user_role_id = ?', UserRole.id_for(:purchase_request_reviewer)).pluck('policy_user_roles.user_id').uniq
    if pr_reviewer_ids.present?
      User.where(id: pr_reviewer_ids).each do |user|
        params = { purchase_requests: PurchaseRequest.awaiting_action_items(user.id) }
        Event::EPurchaseRequest::RemindAwaitingApproval.(user, params) if params.fetch(:purchase_requests).present?
      end
    end 
  end


  def remind_invoice_reviewer
    invoice_reviewer_ids = Policy.where(company_id: 156).joins(:policy_user_roles).where('policy_user_roles.user_role_id = ?', UserRole.id_for(:invoice_reviewer)).pluck('policy_user_roles.user_id').uniq
    if invoice_reviewer_ids.present?
      User.where(id: invoice_reviewer_ids).each do |user|
        non_po_params = { invoices: Invoice.awaiting_action_items(user.id).filter_invoice_type('non_po_invoice') }
        po_params = { invoices: Invoice.awaiting_action_items(user.id).filter_invoice_type('po_invoice') }
        Event::EInvoice::NonPoRemindAwaitingApproval.(user, non_po_params) if non_po_params.fetch(:invoices).present?
        Event::EInvoice::PoRemindAwaitingApproval.(user, po_params) if po_params.fetch(:invoices).present?
      end
    end
  end

  def remind_bank_payment_request_reviewer
    bpr_reviewer_ids = Policy.where(company_id: 156).joins(:policy_user_roles).where('policy_user_roles.user_role_id = ?', UserRole.id_for(:bank_payment_request_reviewer)).pluck('policy_user_roles.user_id').uniq
    if bpr_reviewer_ids.present?
      User.where(id: bpr_reviewer_ids).each do |user|
        params = { bank_payment_requests: BankPaymentRequest.awaiting_action_items(user.id) }
        Event::EBankPaymentRequest::RemindAwaitingApproval.(user, params) if params.fetch(:bank_payment_requests).present?
      end
    end
  end

  def remind_purchase_order_reviewer
    po_reviewer_ids = Policy.where(company_id: 156).joins(:policy_user_roles).where('policy_user_roles.user_role_id = ?', UserRole.id_for(:purchase_order_reviewer)).pluck('policy_user_roles.user_id').uniq
    if po_reviewer_ids.present?
      User.where(id: po_reviewer_ids).each do |user|
        params = { purchase_orders: PurchaseOrder.awaiting_action_items(user) }
        Event::EPurchaseOrder::RemindAwaitingApproval.(user.id, params) if params.fetch(:purchase_orders).present?
      end
    end
  end

end