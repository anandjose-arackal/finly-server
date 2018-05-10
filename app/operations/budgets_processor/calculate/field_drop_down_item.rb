class BudgetsProcessor::Calculate::FieldDropDownItem < BudgetsProcessor::Calculate::Base
  attr_accessor :field_drop_down_item_id, :field_configuration_id

  def init
    self.budget = params[:budget]
    self.spent_amount = 0
    self.field_drop_down_item_id = budget.budgetable_id
  end

  def process
    self.spent_amount += Expense.user_budget_expenses(budget.start_date, budget.end_date).with_category(self.category_id).with_amount.sum(:value)
    self.spend_amount += Payment.budget_payments(budget.start_date, budget.end_date).with_category(self.category_id).with_amount.sum(:value)
  end
end