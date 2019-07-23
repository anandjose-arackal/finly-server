class ReminderAwaitingApprovalPurchaseRequests < ApplicationJob

  def perform
    # Loop through Reviewers and find the awaiting approval items
    pr_reviewer_ids = Policy.where(company_id: 156).joins(:policy_user_roles).where('policy_user_roles.user_role_id = ?', UserRole.id_for(:purchase_request_reviewer)).pluck('policy_user_roles.user_id').uniq
    if pr_reviewer_ids.present?
      User.where(id: pr_reviewer_ids).each do |user|
        params = { purchase_requests: PurchaseRequest.awaiting_action_items(user) }
        Event::EPurchaseRequest::RemindAwaitingApproval.(user.id, params) if params.fetch(:purchase_requests).present?
      end
    end
  end

end