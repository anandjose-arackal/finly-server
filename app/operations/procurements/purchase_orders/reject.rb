class Procurements::PurchaseOrders::Reject < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement, :purchase_order_params

  def init
    purchase_order_id = params[:id] || params[:purchase_order_id]
    self.purchase_order = user.company.purchase_orders.find_by id: purchase_order_id
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end

    unless user_in_level? || user.vendor_payment_admin?
      add_message :error, "Only reviewers in the approval flow or the admin can reject the Purchase Order."
      return
    end
  end

  def process
    params[:document] = self.purchase_order
    params[:aasm_event] = 'reject'
    params[:violation_present] = false #todo Check violations
    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
    end
    self.workflow_output = op.workflow_output
  end

  def post_process
    # todo-olx
    # role_id = self.workflow_output[:role_id]
    Event::EPurchaseOrder::Reject.(user, purchase_order: purchase_order, workflow_output: workflow_output)
    add_message :success, 'Successfully Rejected Purchase Order'
  end

  private

  def document_owner?
    self.purchase_order.user_id.eql?(user.id)
  end

  def user_in_level?
    self.purchase_order.get_reviewers.include?(user)
  end
end