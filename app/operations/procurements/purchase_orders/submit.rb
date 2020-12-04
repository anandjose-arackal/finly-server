class Procurements::PurchaseOrders::Submit < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement, :purchase_order_params,
                :budgets

  def personalizer
    {
        validate: {
            after: Personalizer::Process.new([:procurements, :purchase_orders], :validate, self)
        }
    }
  end

  def rollback_process_if_error?
    true
  end

  def init
    purchase_order_id = params[:id] || params[:purchase_order_id]
    self.purchase_order = user.company.purchase_orders.find_by id: purchase_order_id
    self.procurement = self.purchase_order&.procurement

    fetch_budget_contributions(purchase_order)
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end

    if self.purchase_order.bank_account.disabled
      add_message :error, "This purchase order has a bank account which is disabled. Payment can only be processed to active bank accounts"
      return
    end


    # Set validation of DLRMs
    dlrm_validation_op = ReviewalManager::DocumentReviewalMappings::Validate.(user, {
        reviewal_document: self.purchase_order
    })

    unless dlrm_validation_op.success?
      add_message :error, dlrm_validation_op.messages[:error]
    end
  end

  def process
    params[:document] = self.purchase_order
    params[:aasm_event] = 'submit'
    params[:violation_present] = false
    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    if purchase_order.auto_approved?
      old_status_tag = StatusTag.find_by(id: StatusTag.id_for(:po_processing))
      status_tag = StatusTag.find_by(id: StatusTag.id_for(:po_approved))
      self.procurement.status_tags.delete(old_status_tag)
      self.procurement.status_tags << status_tag
    end

    # if procurements already has advance payments, disallow changes in advance amount even if po revised.
    if purchase_order.advance_amount&.present? and purchase_order.advance_payments.blank?
      if purchase_order.advance_amount.value > 0
        purchase_order.advance_amount_status_id = (purchase_order.auto_approved? ? AdvanceAmountStatus.id_for(:to_be_processed) : AdvanceAmountStatus.id_for(:po_processing))
        purchase_order.save
      end
    end

    self.purchase_order.update(rejection_note: "")
    self.workflow_output = op.workflow_output
  end

  def post_process
    # Budget check
    budget_validation_op = budget_limit_validation(purchase_order)
    if budget_validation_op.present? && budget_validation_op.failure? && budget_validation_op.messages[:errors].present?
      add_message :error, budget_validation_op.messages[:errors]
      return
    end

    add_message :success, 'Successfully submitted purchase order'
    # role_id = self.workflow_output[:role_id]
    Event::EPurchaseOrder::Submit.(user, {purchase_order: purchase_order, workflow_output: workflow_output})
  end
end