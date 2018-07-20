class WorkflowManager::PurchaseOrder < WorkflowManager::Base
  attr_accessor :purchase_order, :aasm_purchase_order, :violations_present, :aasm_event
  def init
    self.purchase_order = params[:purchase_order]
    self.aasm_purchase_order = ::WorkflowManager::Aasm::PurchaseOrder.new self.purchase_order, user
    self.violations_present = params[:violations_present]
    self.aasm_event = params[:aasm_event]
  end

  def validate

  end

  def process
    action = 'may_' + aasm_event + '?'

    may_run = self.aasm_purchase_order.send(action)

    debugger

  end
end