class Procurements::PurchaseOrders::BulkForward < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_orders, :procurement, :policy, :purchase_order_params, :forwarded_to_user, :result

  def init
    self.result = {
        success: [],
        error: []
    }
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
    self.purchase_orders.each do |purchase_order|
      data_success = {}
      data_error = {}
      workflow_input = {
        document: purchase_order,
        aasm_event: 'forward',
        forwarded_to_user: forwarded_to_user
      }

      op = WorkflowManager::Base.(user, workflow_input)
      if op.success?
        data_success[:po_number] = purchase_order&.po_number
        data_success[:sub_department] = purchase_order&.sub_department&.name
        data_success[:department] = purchase_order&.department&.name
        data_success[:user] = purchase_order&.user&.name
        data_success[:amount] = purchase_order&.balance_amount&.value
        self.result[:success].push(data_success)
      else
        data_error[:messages] = op.messages[:error]
        data_error[:po_number] = purchase_order&.po_number
        data_error[:sub_department] = purchase_order&.sub_department&.name
        data_error[:department] = purchase_order&.department&.name
        data_error[:user] = purchase_order&.user&.name
        data_error[:amount] = purchase_order&.balance_amount&.value
        self.result[:error].push(data_error)
      end
    end
  end

  def post_process
    if self.result[:success].length != 0
      add_message :success, "Successfully forwarded #{self.result[:success].length} purchase orders to #{self.forwarded_to_user.name}"
    end

    if self.result[:error].length != 0
      add_message :success, "Couldn't forward #{self.result[:error].length} purchase orders"
    end

    Event::EPurchaseOrder::BulkForward.(user, result: result, forwarded_to_user: forwarded_to_user)
  end
end