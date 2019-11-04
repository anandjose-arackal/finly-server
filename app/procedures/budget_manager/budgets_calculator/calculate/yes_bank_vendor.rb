class BudgetsProcessor::Calculate::YesBankVendor < BudgetsProcessor::Calculate::Base
  attr_accessor :yes_bank_vendor

  def init
    super
    self.yes_bank_vendor = ::YesBankVendor.find_by id: budget.budgetable_id
  end

  def process
    #todo calculate vendor payments
    if items_requested
      payments = Payment.budget_payments(budget.start_date, budget.end_date).with_amount
      self.spent_amount += payments.sum(:value)
      self.budget_trail_items += payments
    else
      # payments = Payment.budget_payments(budget.start_date, budget.end_date).with_category(self.category_id).with_amount.sum(:value)
      self.spent_amount = Payment.budget_payments(budget.start_date, budget.end_date).with_amount.sum(:value)
    end
  end

end