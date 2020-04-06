class Personalizer::Adapters::Company2::Procurements2::PurchaseOrders2::Validate < Personalizer::Adapters::Base
  attr_accessor :purchase_order, :budgets
  def init
    self.purchase_order = op_instance.purchase_order

    # op = BudgetsCalculator::RelevantBudgets.(user, object: self.purchase_order)
    # if op.success?
    #   self.budgets = op.budget_data
    # end
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end
  end

  def process
    # budgets.each do |budget|
    # end
  end

end