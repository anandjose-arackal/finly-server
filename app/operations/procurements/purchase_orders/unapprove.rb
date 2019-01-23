class Procurements::PurchaseOrders::Unapprove < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement

  def init
    purchase_order_id = params[:id] || params[:purchase_order_id]
    # todo scope it and in all similar places
    self.purchase_order = user.company.purchase_orders.find_by id: purchase_order_id

    self.procurement = self.purchase_order&.procurement
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
      return
    end

    unless purchase_order.level.present?
      add_message :error, 'Cannot take action against Purchase Order at this state'
      return
    end

    unless unapprovable?
      add_message :error, 'You cannot unapprove this Purchase Order at this state'
    end
  end

  def process
    params[:document] = self.purchase_order
    params[:aasm_event] = 'unapprove'
    params[:violation_present] = false #todo Check violations
    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end
    # if purchase_order.processing?
    #   old_status_tag = StatusTag.find_by(id: StatusTag.id_for(:po_processing))
    #   status_tag = StatusTag.find_by(id: StatusTag.id_for(:po_approved))
    #   self.procurement.status_tags.delete(old_status_tag)
    #   self.procurement.status_tags << status_tag
    # end

    self.workflow_output = op.workflow_output
  end

  def post_process
    # Event::EPurchaseOrder::Unapprove.(user, purchase_order: purchase_order, workflow_output: self.workflow_output)
    add_message :success, 'Successfully Unapproved Purchase Order'
  end

  def awaiting_action_from?
    # find document level reviewer mapping
    dlrm = purchase_order.document_level_reviewer_mappings.with_level_ids(purchase_order.level&.id)
    level = purchase_order.level

    if dlrm.present?
      # dlrm.pluck(:reviewer_id).include? user.id
      if dlrm.pluck(:reviewer_id).include?(nil)
        level.level_reviewer_mappings.with_threshold(self.purchase_order.balance_amount.value).pluck(:reviewer_id).include? user.id
      else
        dlrm.pluck(:reviewer_id).include? user.id
      end
    else
      level.level_reviewer_mappings.with_threshold(self.purchase_order.balance_amount.value).pluck(:reviewer_id).include? user.id
    end
  end

  def unapprovable?
    # after approval(in previous action by the user)
    # if it has been retracted / approved unapprove action can't be taken
    last_approve_trail = self.purchase_order.trails.only_approve.last
    last_retract_trail = self.purchase_order.trails.only_retract.last
    if last_approve_trail.action_user.id == user.id
      if last_retract_trail.present? && last_retract_trail.created_at > last_approve_trail.created_at
        return false
      end
      return true
    else
      return false
    end
  end
end








