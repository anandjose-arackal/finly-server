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

  def init
    purchase_order_id = params[:id] || params[:purchase_order_id]
    self.purchase_order = user.company.purchase_orders.find_by id: purchase_order_id
    self.procurement = self.purchase_order&.procurement
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end

    # checking for configuration on whether this particular company
    # has budgeting enforced or not
    if self.purchase_order.items.present?
      op = BudgetsCalculator::RelevantBudgets.(user, object: self.purchase_order)
      if op.success?
        self.budgets = op.budget_data
      end
    end
    if current_company.enforce_budget_configuration.enforce_purchase_order_budget? && self.budgets.empty?
      add_message :error, "You cannot submit this PO because there are not budgets associated with it"
      return
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

    self.workflow_output = op.workflow_output
  end

  def post_process
    add_message :success, 'Successfully submitted purchase order'
    Event::EPurchaseOrder::Submit.(user, {purchase_order: purchase_order, workflow_output: workflow_output})
  end
end