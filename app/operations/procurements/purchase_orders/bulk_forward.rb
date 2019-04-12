class Procurements::PurchaseOrders::BulkForward < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_orders, :procurement, :policy, :purchase_order_params, :forwarded_to_user, :result

  def init
    self.result = {}
    unless params[:document_ids].present? || params[:document_ids].is_a?(Array)
      add_message :error, "Invalid Type"
    end

    self.purchase_orders = Procurements::PurchaseOrders::Index.(user, params).purchase_orders.with_id(params[:document_ids])

    if self.purchase_orders&.pluck(:policy_id)&.uniq&.compact&.length > 1
      add_message :error, "Please select invoices from a single policy"
    end

    policy_id = self.purchase_orders&.pluck(:policy_id)&.uniq&.compact&.first
    self.policy = user.company.policies.with_id(policy_id).first

    unless self.policy.present?
      add_message :error, 'Policy not found'
      return
    end

    forwardable_user_ids = self.policy.policy_user_roles.with_role_id(UserRole.id_for(:purchase_order_reviewer)).pluck(:user_id)

    unless forwardable_user_ids.include?(params[:forward_to_id].to_i)
      add_message :error, "Invalid User"
    end

    self.forwarded_to_user = user.company.users.with_id(params[:forward_to_id].to_i).first
  end

  def validate
    unless self.purchase_orders.present?
      add_message :error, 'Purchase Order not found'
      return
    end

    unless self.forwarded_to_user.present?
      add_message :error, "User not found"
    end
  end

  def process
    forwarded = 0
    not_forwarded = 0
    self.purchase_orders.each do |purchase_order|
      workflow_output = {
        document: purchase_order,
        aasm_event: 'forward',
        violation_present: false,
        forwarded_to_user: forwarded_to_user
      }

      op = WorkflowManager::Base.(user, workflow_output)
      if op.success?
        forwarded += 1
      else
        not_forwarded += 1
      end
    end

    self.result[:forwarded] = forwarded
    self.result[:not_forwarded] = not_forwarded
  end

  def post_process
    if self.result[:forwarded] != 0
      add_message :success, "Successfully forwarded #{self.result[:forwarded]} purchase orders to #{self.forwarded_to_user.name}"
    end

    if self.result[:not_forwarded] != 0
      add_message :success, "Couldn't forward #{self.result[:non_forwarded]} purchase orders"
    end

  end
end