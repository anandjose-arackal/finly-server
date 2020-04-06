class Procurements::PurchaseOrders::Reject < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement, :purchase_order_params

  def pre_validate
    if params[:note].blank?
      add_message :error, "Please input a reason for rejection."
      return
    end
  end

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

    if params[:reject_to_user].present? && params[:reject_to_level].present?
      reject_to_details = self.purchase_order.reject_to_users # {dlrm_level_id => reviewer, dlrm_level_id => reviewer, ...}
      
      # if rejection possible to requested level and the requested level has the same user details as sent by FE
      if reject_to_details[params[:reject_to_level].to_i].blank? && (reject_to_details[params[:reject_to_level].to_i].try(:id) != params[:reject_to_user])
        add_message :error, "User details not found for this level"
      end
    end
  end

  def process
    params[:document] = self.purchase_order
    params[:aasm_event] = 'reject'
    params[:violation_present] = false #todo Check violations
    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end
    self.purchase_order.update(rejection_note: params[:note])
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