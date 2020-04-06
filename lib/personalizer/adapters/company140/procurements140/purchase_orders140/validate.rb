class Personalizer::Adapters::Company140::Procurements140::PurchaseOrders140::Validate < Personalizer::Adapters::Base
  attr_accessor :purchase_order, :budgets

  def init
    self.purchase_order = op_instance.purchase_order

    op = BudgetManager::BudgetsCalculator::ApplicableBudgets.({document: self.purchase_order, current_user: User.first})
    if op.success?
      self.budgets = op["result"][:budgets] rescue []
    end
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end
  end

  def process
    # TODO - change the below logic once the ApplicableBudgets has been fixed
    # budgets.each do |budget|
    #   budget_amount = budget.budget_consumption&.budget_amount&.value
    #   budget_spent_amount = budget.budget_consumption&.total_consumed_amount&.value
    #
    #   spent_amount = budget_spent_amount
    #
    #   if spent_amount > budget_amount
    #     add_message :error, "Purchase Order Amount exceeding Budget - #{budget.name}"
    #   end
    # end
    #
    # if messages[:error].present?
    #   add_message :error, 'Please contact finance to allocate more budget'
    # end
  end

end