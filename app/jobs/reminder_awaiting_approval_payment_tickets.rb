class ReminderAwaitingApprovalPaymentTickets < ApplicationJob

  def perform
    # Loop through Reviewers and find the awaiting approval items
    bpr_reviewer_ids = Policy.where(company_id: 156).joins(:policy_user_roles).where('policy_user_roles.user_role_id = ?', UserRole.id_for(:bank_payment_request_reviewer)).pluck('policy_user_roles.user_id').uniq
    if bpr_reviewer_ids.present?
      User.where(id: bpr_reviewer_ids).each do |user|
        params = { bank_payment_requests: PurchaseRequest.awaiting_action_items(user) }
        Event::EPurchaseRequest::RemindAwaitingApproval.(user.id, params) if params.fetch(:bank_payment_requests).present?
      end
    end
  end

end