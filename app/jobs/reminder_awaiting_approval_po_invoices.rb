class ReminderAwaitingApprovalPoInvoices < ApplicationJob

  def perform
    # Loop through Reviewers and find the awaiting approval items
    invoice_reviewer_ids = Policy.joins(:policy_user_roles).where('policy_user_roles.user_role_id = ?', UserRole.id_for(:invoice_reviewer)).pluck('policy_user_roles.user_id').uniq
    if invoice_reviewer_ids.present?
      User.where(id: invoice_reviewer_ids).each do |user|
        params = { invoices: Invoice.awaiting_action_items(user.id).filter_invoice_type('po_invoice') }
        Event::EInvoice::PoRemindAwaitingApproval.(user, params) if params.fetch(:invoices).present?
      end
    end
  end
end