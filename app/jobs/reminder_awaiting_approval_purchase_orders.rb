class ReminderAwaitingApprovalPurchaseOrders < ApplicationJob

  def perform
    # Loop through Reviewers and find the awaiting approval purchase orders
    po_reviewer_ids = Policy.where(company_id: 156).joins(:policy_user_roles).where('policy_user_roles.user_role_id = ?', UserRole.id_for(:purchase_order_reviewer)).pluck('policy_user_roles.user_id').uniq
    if po_reviewer_ids.present?
      User.where(id: po_reviewer_ids).each do |user|
        params = { purchase_orders: PurchaseOrder.awaiting_action_items(user) }
        Event::EPurchaseOrder::RemindAwaitingApproval.(user, params) if params.fetch(:purchase_orders).present?
      end
    end
  end

end