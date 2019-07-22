class ReminderAwaitingApprovalPurchaseOrders < ApplicationJob

  def perform
    # Loop through Reviewers and find the awaiting approval purchase orders
    po_reviewer_ids = Policy.joins(:policy_user_roles).where('policy_user_roles.user_role_id = ?', UserRole.id_for(:purchase_order_reviewer)).pluck('policy_user_roles.user_id').uniq
    User.where(id: po_reviewer_ids).each do |user|
      params = { purchase_orders: PurchaseOrder.reviewer_associated_items(user) }
      Event::EPurchaseOrder::RemindAwaitingApproval.(user, params) if params.fetch(:purchase_orders).present?
    end
  end

end